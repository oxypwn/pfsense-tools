/*-
 * ----------------------------------------------------------------------------
 * "THE BEER-WARE LICENSE" (Revision 42):
 * <csjp@sqrt.ca> wrote this file.  As long as you retain this notice you
 * can do whatever you want with this stuff. If we meet some day, and you think
 * this stuff is worth it, you can buy me a beer in return. Christian S.J Peron
 * ----------------------------------------------------------------------------
 */
#include <sys/types.h>
#include <sys/queue.h>
#include <sys/uio.h>
#include <sys/stat.h>
#include <sys/wait.h>

#include <dirent.h>
#include <unistd.h>
#include <stdio.h>
#include <termios.h>
#include <string.h>
#include <fcntl.h>
#include <ctype.h>
#include <errno.h>
#include <stdlib.h>
#include <assert.h>
#include <err.h>
#include <libgen.h>

#include "vtsh.h"

static char	 rootpath[256];
static char	*fflag;
static int	 bflag;

static char *
vt_auto_complete(char *curbuf, int *pos)
{
	struct cmd_vec *cv;
	struct vector *v;
	struct dirent *dp;
	DIR *dirp;
	int len, ndirs;
	char *ac;

	if (*curbuf == 0)
		return (NULL);
	cv = vt_build_cmd_vec(curbuf);
	if (cv == NULL)
		return (NULL);
	ndirs = vt_set_cmd_dir(cv);
	if (ndirs != cv->nelmts) {
		if (chdir(rootpath) < 0)
			err(1, "chdir failed");
		return (NULL);
	}
	if (chdir("..") < 0)
		err(1, "chdir failed");
	ac = "";
	dirp = opendir(".");
	ndirs = 0;
	while ((dp = readdir(dirp)) != NULL) {
		if (!strcmp(dp->d_name, ".") ||
		    !strcmp(dp->d_name, ".."))
			continue;
		if (dp->d_type != DT_DIR)
			continue;
		assert(cv->v_last != NULL);
		len = strlen(cv->v_last->piece);
		if (strncmp(dp->d_name, cv->v_last->piece, len) == 0) {
			ac = dp->d_name + len;
			ndirs++;
		}
	}
	vt_cmd_vec_dtor(cv);
	if (chdir(rootpath) < 0)
		err(1, "chdir failed");
	/*
	 * If more than one entry matched, the supplied text is
	 * too ambiguous
	 */
	if (ndirs > 1)
		ac = "";
	putchar('\n');
	vt_print_prompt();
	strcat(curbuf, ac);
	strcat(curbuf, " ");
	*pos += strlen(ac) + 1;
	printf("%s", curbuf);
	fflush(stdout);
	return (ac);
}

static int
vt_check_dir(int what)
{
	struct dirent *dp;
	DIR *dirp;

	dirp = opendir(".");
	while ((dp = readdir(dirp)) != NULL) {
		if (!strcmp(dp->d_name, ".") ||
		    !strcmp(dp->d_name, ".."))
			continue;
		if (what == VTY_CHECK_CHILDREN &&
		    dp->d_type == DT_DIR)
			return (1);
		else if (what == VTY_CHECK_SCRIPT &&
		    !strcmp(dp->d_name, S_EXEC))
			return (1);
	}
	return (0);
}

static void
vt_set_tty(int vt_fd, struct termios *saved)
{
	struct termios new;

	tcgetattr(vt_fd, saved);
	new = *saved;
	new.c_lflag &= ~(ECHO | ICANON);
	tcsetattr(vt_fd, TCSAFLUSH, &new);
}

static void
vt_cmd_vec_dtor(struct cmd_vec *cv)
{
	struct vector *v, *v_next;

	assert(cv != NULL);
	TAILQ_FOREACH_SAFE(v, &cv->head, glue, v_next) {
		free(v->piece);
		TAILQ_REMOVE(&cv->head, v, glue);
		free(v);
	}
	free(cv->copy);
	free(cv);
}

struct cmd_vec *
vt_build_cmd_vec(char *cmd)
{
	struct cmd_vec *cv;
	struct vector *v;
	char *piece;

	assert(cmd != NULL);
	cv = calloc(1, sizeof(*cv));
	if (cv == NULL) {
		warn("calloc failed");
		return (NULL);
	}
	/*
	 * I think we can trust that the calloc(3) implementation complies
	 * with ISO/IEC 9899:1990 (``ISO C90''), but we will drop these
	 * assertions in here just in case
	 */
	assert(cv->nelmts == 0);
	assert(cv->mode == 0);
	v = NULL;
	cv->flag = T_ACTIVATE;
	cv->copy = strdup(cmd);
	if (cv->copy == NULL) {
		warn("strdup failed");
		free(cv);
		return (NULL);
	}
	TAILQ_INIT(&cv->head);
	/*
	 * strsep clobbers the string, so create a copy of it which we
	 * can smash, leaving the original un-touched.
	 */
	while ((piece = strsep(&cv->copy, " \t")) != NULL) {
		if (*piece == 0)
			continue;
		if (cv->nelmts++ == 0 && strcmp("no", piece) == 0) {
			cv->flag = T_DEACTIVATE;
			continue;
		}
		v = malloc(sizeof(*v));
		if (v == NULL) {
			warn("malloc failed");
			free(cv);
			return (NULL);
		}
		v->piece = strdup(piece);
		if (v->piece == NULL) {
			warn("strdup failed");
			free(cv);
			return (NULL);
		}
		v->directory = 0;
		TAILQ_INSERT_HEAD(&cv->head, v, glue);
	}
	if (v != NULL)
		cv->v_last = v;
	return (cv);
}

char **
vt_build_argv(struct cmd_vec *cv)
{
	static char *argv[64];
	struct vector *v;
	int index;

	assert(cv != NULL);
	index = 0;
	argv[index++] = (cv->flag == T_ACTIVATE) ?
	    S_EXEC : S_NOEXEC;
	TAILQ_FOREACH_REVERSE(v, &cv->head, tailhead, glue)
		if (v->directory != 1)
			argv[index++] = v->piece;
	argv[index] = 0;
	return (argv);
}

char *
vt_find_partial_match(char *part)
{
        struct dirent *dp;
        DIR *dirp;
	int len;
	char *path;
	int count;

	len = strlen(part);
        dirp = opendir(".");
	count = 0;
        while ((dp = readdir(dirp)) != NULL) {
		if (!strcmp(dp->d_name, ".") ||
		    !strcmp(dp->d_name, ".."))
			continue;
		if (dp->d_type == DT_DIR &&
		    strncmp(dp->d_name, part, len) == 0) {
			count++;
			path = dp->d_name;
		}
	}
	if (count > 1)
		return (NULL);
        return (path);
}

static int
vt_set_cmd_dir(struct cmd_vec *cv)
{
	int error, nchdirs;
	char *dirname, *section;
	struct vector *v;

	assert(cv != NULL);
	nchdirs = 0;
	TAILQ_FOREACH_REVERSE(v, &cv->head, tailhead, glue) {
		/*
		 * Extract the basename of the path supplied. This will
		 * convert names like: "../enable/show" to "show"
		 */
		dirname = basename(v->piece);
		if (dirname == NULL) {
			warn("%s", v->piece);
			continue;
		}
		error = chdir(dirname);
		switch (error) {
		case -1:
			section = vt_find_partial_match(dirname);
			if (section == NULL)
				break;
			error = chdir(section);
			if (error < 0) 
				break;
			/* FALL THROUGH */
		default:
			v->directory = 1;
			nchdirs++;
		}
	}
	assert(cv->mode == 0);
        if (vt_check_dir(VTY_CHECK_SCRIPT))
                cv->mode |= D_HASSCRIPTS;
        if (vt_check_dir(VTY_CHECK_CHILDREN))
                cv->mode |= D_HASCHILDREN;
	return (nchdirs);
}

static void
vt_context_help(char *currentbuf)
{
	struct cmd_vec *cv;
	int status, pid;

	pid = fork();
	if (pid < 0)
		err(1, "fork failed");
	if (pid == 0) {
		cv = vt_build_cmd_vec(currentbuf);
		if (cv == NULL) {
			warn("null command vector");
			_exit(1);
		}
		status = vt_set_cmd_dir(cv);
		if (status == 0 && cv->nelmts != 0) {
			printf("\n%% Unrecognized command\n");
			_exit(1);
		} else if (cv->nelmts != status) {
			printf("\n%% Invalid input detected at '^' marker.\n");
			_exit(1);
		}
		vt_cmd_vec_dtor(cv);
		execl(_PATH_PAGER, _PATH_PAGER, "help", 0);
		err(1, "execl failed");
	}
	while (waitpid(pid, &status, 0) < 0) {
		if (errno != EINTR) {
			status = -1;
			break;
		}
	}
	vt_print_prompt();
}

static int
vt_execute_cmd(struct cmd_vec *cv)
{
	int nc, status, pid;
	struct vector *v;
	char **argv;

	argv = vt_build_argv(cv);
	nc = vt_set_cmd_dir(cv);
	if (nc == 0) {
		printf("%% Unrecognized command\n");
		return (1);
	} 
	if (cv->nelmts - nc < vt_get_cmd_nargs()) {
		printf("%% Incomplete command\n");
		return (1);
	}
	if ((cv->mode & D_HASCHILDREN) != 0 &&
	    (cv->mode & D_HASSCRIPTS) == 0) {
		printf("%% Type \"");
		TAILQ_FOREACH_REVERSE(v, &cv->head, tailhead, glue)
			if (v->directory == 1)
				printf("%s ", v->piece);
		printf("?\" for a list of subcommands\n");
		return (1);
	}
	pid = fork();
	if (pid < 0)
		err(1, "fork failed");
	if (pid == 0) {
		execv(*argv, argv);
		err(1, "execve failed");
	}
	while (waitpid(pid, &status, 0) < 0) {
		if (errno != EINTR) {
			status = -1;
			break;
		}
	}
	return (status);
}

static void
vt_restore_tty(int vt_fd, struct termios *saved)
{

	tcsetattr(vt_fd, TCSANOW, saved);
}

static int
vt_get_cmd_nargs(void)
{
	struct stat sb;
	char pbuf[32];
	int error, fd;

	fd = open("minargs", O_RDONLY);
	if (fd < 0)
		return (0);
	if (fstat(fd, &sb) < 0) {
		close(fd);
		return (0);
	}
	error = read(fd, &pbuf[0], sb.st_size - 1);
	if (error < 0) {
		close(fd);
		return (0);
	}
	close(fd);
	return (atoi(&pbuf[0]));
}

static char *
vt_build_prompt(void)
{
	char path[128], pbuf[32];
	struct stat sb;
	int error, fd;
	char *prompt;

	snprintf(path, sizeof(path) - 1,
	    "%s/prompt", rootpath);
	bzero(pbuf, sizeof(pbuf));
	fd = open(path, O_RDONLY);
	prompt = "(none)$ ";
	if (fd < 0)
		warn("open failed");
	else if (fstat(fd, &sb) < 0)
		warn("fstat failed");
	else if ((error = read(fd, &pbuf[0],
	    sb.st_size - 1)) < 0)
		warn("read failed");
	else
		prompt = strdup(pbuf);
	close(fd);
	return (prompt);
}

static void
vt_print_prompt(void)
{
	char hostname[256];
	static char *p;

	gethostname(&hostname[0], sizeof(hostname));
	if (p == NULL)
		p = vt_build_prompt();
	printf("%s%s", hostname, p);
	fflush(stdout);
}

static void
vt_rubout(int vt_fd)
{
	int error;
	char rub[3];

	rub[0] = C_BACKSPACE;
	rub[1] = ' ';
	rub[2] = C_BACKSPACE;
	error = write(vt_fd, &rub[0], 3);
	if (error < 0)
		err(1, "write failed");
}

static char *
vt_read_cmd(int vt_fd)
{
	unsigned char *ac, c, buf[1024];
	int error, pos;

	pos = c = 0;
	bzero(&buf[0], sizeof(buf));
	while (c != '\r' && c != '\n') {
		error = read(vt_fd, &c, 1);
		if (error < 0)
			return (NULL);
		if (c == '1') {
			printf("\ncurbuf=%s\n", buf);
			continue;
		}
		if (c == C_BACKSPACE) {
			if (pos == 0)
				continue;
			buf[--pos] = 0;
			vt_rubout(vt_fd);
			continue;
		} 
		if (c == '?') {
			putchar('?');
			fflush(stdout);
			vt_context_help(buf);
			printf("%s", buf);
			fflush(stdout);
			continue;
		}
		if (c == '\t') {
			vt_auto_complete(&buf[0], &pos);
			continue;
		}
		buf[pos++] = c;
		if (isprint(c))
			putchar(c);
		fflush(stdout);
	}
	buf[--pos] = 0;
	putchar('\n');
	return (strdup(&buf[0]));
}

char *
chomp(char *s)
{
	char *p;

	while ((p = strchr(s, '\n'))) {
		*p = '\0';
		p++;
	}
	return (s);
}

static void
vt_read_conf_file(char *filename)
{
	struct cmd_vec *cv;
	char inbuf[1024];
	FILE *fp;

	fp = fopen(filename, "r");
	if (fp == NULL)
		err(1, "fopen failed");
	while (fgets(inbuf, sizeof(inbuf), fp)) {
		if (chdir(rootpath) < 0)
			err(1, "chdir failed");
		if (*inbuf == '!' || *inbuf == '\n' ||
		    *inbuf == '\r')
			continue;
		chomp(inbuf);
		cv = vt_build_cmd_vec(inbuf);
		if (cv == NULL)
			continue;
		vt_execute_cmd(cv);
		vt_cmd_vec_dtor(cv);
	}
	fclose(fp);
}

static void
vt_read_conf_tty(void)
{
	struct termios saved;
	struct cmd_vec *cv;
	char *cmd;
	int vt_fd;

	vt_fd = fileno(stdin);
	vt_set_tty(vt_fd, &saved);
	for (;;) {
		if (chdir(rootpath) < 0)
			err(1, "chdir failed");
		vt_print_prompt();
		cmd = vt_read_cmd(vt_fd);
		if (cmd == NULL)
			break;
		if (strncmp(cmd, "exit", 4) == 0)
			break;
		cv = vt_build_cmd_vec(cmd);
		if (cv == NULL) {
			free(cmd);
			continue;
		}
		if (cv->nelmts == 0) {
			free(cmd);
			continue;
		}
		vt_execute_cmd(cv);
		vt_cmd_vec_dtor(cv);
		free(cmd);
	}
	vt_restore_tty(vt_fd, &saved);
}

int
main(int argc, char *argv [])
{
	int ch;
	char *mode;

	while ((ch = getopt(argc, argv, "bf:")) != -1)
		switch (ch) {
		case 'b':
			bflag++;
			break;
		case 'f':
			fflag = optarg;
			break;
		}
	argv += optind;
	argc -= optind;
	if (argv[0] != NULL)
		mode = argv[0];
	else
		mode = "default";
	(void)snprintf(rootpath, sizeof(rootpath) - 1,
	    "%s/%s", _PATH_VTYSH, mode);
	if (chdir(rootpath) < 0)
		err(1, "chdir failed");
	if (bflag) {
		vt_read_conf_file("startup-config");
		return (0);
	}
	if (fflag)
		vt_read_conf_file(fflag);
	else
		vt_read_conf_tty();
	return (0);
}
