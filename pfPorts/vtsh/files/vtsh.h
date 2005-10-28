/*-
 * ----------------------------------------------------------------------------
 * "THE BEER-WARE LICENSE" (Revision 42):
 * <csjp@sqrt.ca> wrote this file.  As long as you retain this notice you
 * can do whatever you want with this stuff. If we meet some day, and you think
 * this stuff is worth it, you can buy me a beer in return. Christian S.J Peron
 * ----------------------------------------------------------------------------
 */
#ifndef	VTYSH_H_
#define	VTYSH_H_

struct tailhead;
struct vector {
        TAILQ_ENTRY(vector) glue;
        char    *piece;
	int	directory;
};

struct cmd_vec {
        TAILQ_HEAD(tailhead, vector) head;
	char	*copy;
        int     nelmts;
        int     flag;
	int	mode;
	struct vector *v_last;
#define T_ACTIVATE      1
#define T_DEACTIVATE    2

#define	D_HASCHILDREN	0x000001
#define	D_HASSCRIPTS	0x000002
#define VTY_CHECK_CHILDREN      1
#define VTY_CHECK_SCRIPT        2
};

#define C_BACKSPACE     0x08
#define	_PATH_VTYSH	"/usr/local/vtsh"
#define	S_EXEC		"activate.sh"
#define	S_NOEXEC	"deactivate.sh"
#define	_PATH_PAGER	"/usr/bin/more"

static int	 vt_check_dir(int);
static void	 vt_set_tty(int, struct termios *);
struct cmd_vec	*vt_build_cmd_vec(char *);
char		**vt_build_argv(struct cmd_vec *);
char		*vt_find_partial_match(char *);
static int	 vt_set_cmd_dir(struct cmd_vec *);
static void	 vt_context_help(char *);
static int	 vt_execute_cmd(struct cmd_vec *);
static void	 vt_restore_tty(int, struct termios *);
static int	 vt_get_cmd_nargs(void);
static void	 vt_rubout(int);
static char	*vt_read_cmd(int);
static void	 vt_cmd_vec_dtor(struct cmd_vec *);
static void	 vt_read_conf_file(char *);
static void	 vt_print_prompt(void);

#endif	/* VTYSH_H_ */
