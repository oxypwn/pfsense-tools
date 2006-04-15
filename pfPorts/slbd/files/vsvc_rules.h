/* 
 * $Id$
 *
 * Copyright (c) 2003, Silas Partners
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 *     - Redistributions of source code must retain the above copyright notice,
 *       this list of conditions and the following disclaimer.
 *     - Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     - Neither the name of Christianity.com nor the names of its
 *       contributors may be used to endorse or promote products derived from
 *       this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 *
 */

/* 
 * needs globals.h service.h vsvc.h pfctl/pfctl.h pfctl/pfctl_parser.h
*/

extern char *anchorname;
#ifdef OpenBSD3_5
extern char *anchorname;
#endif

int		vsvc_ruleinit(void);
int		vsvc_rulefetch(struct vsvc_t *, struct pf_rule *);
int		vsvc_ruleadd(struct vsvc_t *);
int		vsvc_ruleupdate(struct vsvc_t *);
struct pf_rule *vsvc_rulecreate(struct vsvc_t *);
int		vsvc_rulesetdestroy();

int		vsvc_pfctlstart();
int		vsvc_pfctlstop();
int		vsvc_pfctllock();
int		vsvc_pfctlunlock();
int		vsvc_pfctlclear();
#define	vsvc_pfctlgetstatus()	(pfcontrol.status)

int		vsvc_poolupdate(struct vsvc_t *);
/* int vsvc_commit_rule(struct vsvc_t *, struct pf_rule *); redundant? */


