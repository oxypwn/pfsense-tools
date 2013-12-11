
#include <sys/types.h>
#include <sys/sbuf.h>
#include <sys/socket.h>
#include <sys/un.h>

#include <netinet/in.h>
#include <arpa/inet.h>

#include <err.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <unistd.h>
#include <libgen.h>

#define VERSION	1

enum reqtype {
	BEGINREQUEST = 1,
	ABORTREQUEST,
	ENDREQUEST,
	PARAMS,
	STDIN,
	STDOUT,
	STDERR,
	DATA,
	GETVALUES,
	GETVALUESRESULT,
	MAXTYPE
};

enum clitype {
	RESPONDER = 1,
	AUTHORIZER,
	FILER
};

enum reqstatus {
	REQUESTCOMPLETE = 0,
	CANTMULTIPLEX,
	OVERLOADED,
	UNKOWNROLE
};

enum respindex {
	respversion = 0,
	resptype,
	resprequestId,
	respcontentLength,
	resppaddingLength,
	respreserved,
	respcontent,
	respMAX
};

#define HEADERLEN	8

static int fcgisock = -1;
static struct sockaddr_un sun;
static struct sockaddr_in sin;
static int keepalive = 1;

static int
build_nvpair(struct sbuf *sb, const char *key, const char *value)
{
	int lkey, lvalue;

	lkey = strlen(key);
	lvalue = strlen(value);

	if (lkey < 128)
		sbuf_printf(sb, "%c", (char)lkey);
	else
		sbuf_printf(sb, "%c%c%c%c", (char)((lkey >> 24) | 0x80), (char)((lkey >> 16) & 0xFF), (char)((lkey >> 16) & 0xFF), (char)(lkey & 0xFF));

	if (lkey < 128)
		sbuf_printf(sb, "%c", (char)lvalue);
	else
		sbuf_printf(sb, "%c%c%c%c", (char)((lvalue >> 24) | 0x80), (char)((lvalue >> 16) & 0xFF), (char)((lvalue >> 16) & 0xFF), (char)(lvalue & 0xFF));

	sbuf_printf(sb, "%s%s", key, value);

	return (0);
}

static int
build_packet(struct sbuf *sb, int type, char *content, int requestId)
{
	int lcontent;

	if (content == NULL)
		lcontent = 0;
	else
		lcontent = strlen(content);

	sbuf_printf(sb, "%c%c%c%c%c%c%c%c%s", (char)VERSION, (char)type, (char)((requestId >> 8) & 0xFF),
			(char)(requestId & 0xFF), (char)((lcontent >> 8) & 0xFF), (char)(lcontent & 0xFF),
			(char)0, (char)0, content);

	return (0);
}

static int
read_packet(struct sbuf *sb, int sockfd, int *header)
{
	char data[HEADERLEN];
	char buf[2048];
	int len, err;

	memset(header, 0, sizeof(int) * HEADERLEN);
	memset(data, 0, sizeof(char) * HEADERLEN);
	if (read(sockfd, data, HEADERLEN) >= 0) {
		header[respversion] = (int)data[0];
		header[resptype] = (int)data[0];
		header[resprequestId] = (int)(((int)((data[2] << 8))) + ((int)(data[3])));
		header[respcontentLength] = (int)(((int)((data[4] << 8))) + ((int)(data[5])));
		header[resppaddingLength] = (int)data[6];
		header[respreserved] = (int)data[7];

		if (header[respcontentLength] > 0) {
			memset(buf, 0, sizeof(buf));
			len = header[respcontentLength];
			while (len > 0 && (err = read(sockfd, buf, sizeof(buf)))) {
				if (err < 0) {
					printf("Something wrong happened while reading from socket\n");
					return (-1);
				}
				len -= err;
				sbuf_printf(sb, "%s", buf);
				memset(buf, 0, sizeof(buf));
			}
		}
		
		return (0);
	} else
		return (-1);
}

static void
usage()
{
	printf("Usage: fcgicli [-d key=value] -f phpfiletocall -s phpfcgisocket -o [POST|GET]\n");
	exit(-10);
}

int
main(int argc, char **argv)
{
	struct sbuf *sb, *sbtmp2, *sbtmp;
	int ch, ispost = 0, len;
	char *data = NULL, *script = NULL, *socketpath = NULL, *mtype = NULL;
	int header[respMAX];

	while ((ch = getopt(argc, argv, "d:f:s:o:")) != -1) {
		switch (ch) {
		case 'd':
			data = optarg;
			break;
		case 'f':
			script = optarg;
			break;
		case 's':
			socketpath = optarg;
			break;
		case 'o':
			if (!strcasecmp(optarg, "POST"))
				ispost = 1;
			else if(!strcasecmp(optarg, "GET"))
				ispost = 0;
			else
				usage();

			mtype = optarg;
			break;
		}
	}
	argc -= optind;
        argv += optind;

	if (socketpath == NULL) {
		printf("-s option is mandatory\n");
		usage();
	}
	if (data != NULL && ispost) {
		printf("-d option is useful only with POST operation\n");
		usage();
	}

	if (strstr(socketpath, "/")) {
		fcgisock = socket(PF_INET, SOCK_STREAM, 0);
		if (fcgisock < 0)
			err(-2, "could not create socket.");

		bzero(&sun, sizeof(sun));
		sun.sun_family = AF_LOCAL;
		strlcpy(sun.sun_path, socketpath, sizeof(sun.sun_path));
		len = sizeof(sun);

		//alarm(3); /* Wait 3 seconds to complete a connect. More than enough?! */
		if (connect(fcgisock, (struct sockaddr *)&sun, len) < 0)
			errx(errno, "Could not connect to server.");
	} else {
		char *host, *port;
		if (!(port = strstr(socketpath, ":")))
			errx(-1, "Need the port specified as host:port");

		*port++ = '\0';
		host = socketpath;

		fcgisock = socket(PF_UNIX, SOCK_STREAM, 0);
		if (fcgisock < 0)
			err(-2, "could not create socket.");

		bzero(&sin, sizeof(sin));
		sin.sin_family = AF_INET;
		inet_pton(AF_INET, host, &sin.sin_addr); 
		sin.sin_port = htons(atoi(port));
		len = sizeof(sin);

		//alarm(3); /* Wait 3 seconds to complete a connect. More than enough?! */
		if (connect(fcgisock, (struct sockaddr *)&sin, len) < 0)
			errx(errno, "Could not connect to server.");
	}

	sb = sbuf_new_auto();
	if (sb == NULL)
		errx(-3, "Could not allocate memory\n");

	sbtmp = sbuf_new_auto();
	if (sbtmp == NULL)
		errx(-3, "Could not allocate memory\n");

	if (ispost) {
		
	} else {
		sbuf_printf(sbtmp, "0%c%c00000", (char)RESPONDER, (char)keepalive);
		sbuf_finish(sbtmp);
		if (build_packet(sb, BEGINREQUEST, sbuf_data(sbtmp), 1))
			errx(-4, "Could not build start of request");
		sbuf_delete(sbtmp);
		
		sbtmp2 = sbuf_new_auto();
		build_nvpair(sbtmp2, "GATEWAY_INTERFACE", "FastCGI/1.0");
		build_nvpair(sbtmp2, "REQUEST_METHOD", "GET");
		build_nvpair(sbtmp2, "SCRIPT_FILENAME", script);
		sbtmp = sbuf_new_auto();
		sbuf_printf(sbtmp, "/%s", basename(script));
		sbuf_finish(sbtmp);
		build_nvpair(sbtmp2, "SCRIPT_NAME", sbuf_data(sbtmp));
		build_nvpair(sbtmp2, "DOCUMENT_URI", sbuf_data(sbtmp));
		if (data == NULL) {
			build_nvpair(sbtmp2, "REQUEST_URI", sbuf_data(sbtmp));
			build_nvpair(sbtmp2, "QUERY_STRING", "");
		}
		sbuf_delete(sbtmp);
		if (data) {
			build_nvpair(sbtmp2, "QUERY_STRING", data); 
			sbtmp = sbuf_new_auto();
			sbuf_printf(sbtmp, "/%s?%s", basename(script), data);
			sbuf_finish(sbtmp);
			build_nvpair(sbtmp2, "REQUEST_URI", sbuf_data(sbtmp));
			sbuf_delete(sbtmp);
		}
		build_nvpair(sbtmp2, "SERVER_SOFTWARE", "php/fcgiclient");
		build_nvpair(sbtmp2, "REMOTE_ADDR", "localhost");
		build_nvpair(sbtmp2, "REMOTE_PORT", "9999");
		build_nvpair(sbtmp2, "SERVER_ADDR", "localhost");
		build_nvpair(sbtmp2, "SERVER_PORT", "80");
		build_nvpair(sbtmp2, "SERVER_NAME", "fcgicli");
		build_nvpair(sbtmp2, "SERVER_PROTOCOL", "HTTP/1.1");
		build_nvpair(sbtmp2, "CONTENT_TYPE", "");
		build_nvpair(sbtmp2, "CONTENT_LENGTH", "0");
		sbuf_finish(sbtmp2);
		build_packet(sb, PARAMS, sbuf_data(sbtmp2), 1);
		sbuf_delete(sbtmp2);
	}
	build_packet(sb, PARAMS, NULL, 1);
	build_packet(sb, STDIN, NULL, 1);
	sbuf_finish(sb);
	if (write(fcgisock, sbuf_data(sb), sbuf_len(sb)) != sbuf_len(sb)) {
		printf("Something wrong happened\n");
		sbuf_delete(sb);
		close(fcgisock);
		exit(-2);
	}
	sbuf_delete(sb);

	do {
		sb = sbuf_new_auto();
		ch = read_packet(sb, fcgisock, header);
		if (ch < 0) {
			printf("Something wrong happened while reading request\n");
			//sbuf_finish(sb);
			//sbuf_delete(sb);
			break;
		}
		sbuf_finish(sb);
		if (header[resptype] == STDOUT || header[resptype] == STDERR) {
			printf("%s", sbuf_data(sb));
			sbuf_delete(sb);
		}
	} while (header[resptype] != ENDREQUEST);

	if (ch > 0) {
		data = sbuf_data(sb);
		switch ((int)data[4]) {
		case CANTMULTIPLEX:
			printf("The FCGI server cannot multiplex\n");
			break;
		case OVERLOADED:
			printf("The FCGI server is overloaded\n");
			break;
		case UNKOWNROLE:
			printf("FCGI role is unknown\n");
			break;
		case REQUESTCOMPLETE:
			printf("%s", data);
			break;
		}
		sbuf_delete(sb);
	}

	close(fcgisock);

	return (0);
}
