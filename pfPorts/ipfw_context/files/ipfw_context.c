
#include <sys/types.h>
#include <sys/socket.h>

#include <net/if.h>
#include <net/if_var.h>

#include <netinet/in.h>

#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <err.h>

#define IP_FW_CTX_MAXNAME       64

struct ip_fw_ctx_member {
        char ctxname[IP_FW_CTX_MAXNAME];
        char ifname[IFNAMSIZ];
};


int main(int argc, char **argv)
{
	struct ip_fw_ctx_member ctxmember;
	int ch, s, error = 0, action = 0;
	socklen_t len = 10000;
	char context[IP_FW_CTX_MAXNAME], member[IFNAMSIZ], buf[10000];

	while ((ch = getopt(argc, argv, "a:d:ln:s:x:")) != -1) {
		switch (ch) {
		case 'a':
			strlcpy(context, optarg, sizeof(context));
			action = IP_FW_CTX_ADD;
			break;
		case 'd':
			strlcpy(context, optarg, sizeof(context));
			action = IP_FW_CTX_DEL;
			break;
		case 'n':
			strlcpy(member, optarg, sizeof(member));
			action = IP_FW_CTX_ADDMEMBER;
			break;
		case 's':
			strlcpy(context, optarg, sizeof(context));
			action = IP_FW_CTX_SET;
			break;
		case 'x':
			strlcpy(member, optarg, sizeof(member));
			action = IP_FW_CTX_DELMEMBER;
			break;
		case 'l':
			action = IP_FW_CTX_GET;
			break;
		default:
			printf("Unknown option passed\n");
			return (-1);
		}

	}

	if (context == NULL)
		errx(-1, "context");

	s = socket(AF_INET, SOCK_RAW, IPPROTO_RAW);
	if (s < 0)
		errx(-1, "socket");

	switch (action) {
	case IP_FW_CTX_ADD:
	case IP_FW_CTX_DEL:
	case IP_FW_CTX_SET:
		error = setsockopt(s, IPPROTO_IP, action, (void *)context, strlen(context));
		break;
	case IP_FW_CTX_ADDMEMBER:
	case IP_FW_CTX_DELMEMBER:
		if (member == NULL)
			errx(-1, "member");
		strlcpy(ctxmember.ifname, member, sizeof(ctxmember.ifname));
		strlcpy(ctxmember.ctxname, context, sizeof(ctxmember.ctxname));
		error = setsockopt(s, IPPROTO_IP, action, &ctxmember, sizeof(ctxmember));
		break;
	case IP_FW_CTX_GET:
		error = getsockopt(s, IPPROTO_IP, action, (void *)buf, &len);
		if (len > 10000)
			printf("Buffer is too small\n");
		else if (!error)
			printf("Currently defined contextes and their members:\n%s\n", buf);
		break;
	}

	if (error)
		printf("Error is: %s", strerror(error));

	close(s);

	return (error);
}
