# This Makefile is for the LWP extension to perl.
#
# It was generated automatically by MakeMaker version
# 7.3 (Revision: 73000) from the contents of
# Makefile.PL. Don't edit this file, edit Makefile.PL instead.
#
#       ANY CHANGES MADE HERE WILL BE LOST!
#
#   MakeMaker ARGV: (q[PREFIX=/home/fabricio/Downloads/sas/modules], q[LIB=/home/fabricio/Downloads/sas/modules/lib])
#

#   MakeMaker Parameters:

#     ABSTRACT => q[The World-Wide Web library for Perl]
#     AUTHOR => [q[Gisle Aas <gisle@activestate.com>]]
#     BUILD_REQUIRES => {  }
#     CONFIGURE_REQUIRES => {  }
#     DISTNAME => q[libwww-perl]
#     EXE_FILES => []
#     LICENSE => q[perl]
#     META_MERGE => { recommends=>{ Crypt::SSLeay=>q[0] }, resources=>{ MailingList=>q[mailto:libwww@perl.org], repository=>q[http://gitorious.org/projects/libwww-perl] } }
#     MIN_PERL_VERSION => q[5.006]
#     NAME => q[LWP]
#     PREREQ_PM => { Compress::Raw::Zlib=>q[0], Digest::MD5=>q[0], HTML::Parser=>q[3.33], HTML::Tagset=>q[0], IO::Compress::Deflate=>q[0], IO::Compress::Gzip=>q[0], IO::Uncompress::Gunzip=>q[0], IO::Uncompress::Inflate=>q[0], IO::Uncompress::RawInflate=>q[0], MIME::Base64=>q[2.1], Net::FTP=>q[2.58], URI=>q[1.10] }
#     TEST_REQUIRES => {  }
#     VERSION_FROM => q[lib/LWP.pm]
#     clean => { FILES=>q[] }

# --- MakeMaker post_initialize section:


# --- MakeMaker const_config section:

# These definitions are from config.sh (via /usr/lib/x86_64-linux-gnu/perl/5.22/Config.pm).
# They may have been overridden via Makefile.PL or on the command line.
AR = ar
CC = x86_64-linux-gnu-gcc
CCCDLFLAGS = -fPIC
CCDLFLAGS = -Wl,-E
DLEXT = so
DLSRC = dl_dlopen.xs
EXE_EXT = 
FULL_AR = /usr/bin/ar
LD = x86_64-linux-gnu-gcc
LDDLFLAGS = -shared -L/usr/local/lib -fstack-protector-strong
LDFLAGS =  -fstack-protector-strong -L/usr/local/lib
LIBC = libc-2.23.so
LIB_EXT = .a
OBJ_EXT = .o
OSNAME = linux
OSVERS = 3.16.0
RANLIB = :
SITELIBEXP = /usr/local/share/perl/5.22.1
SITEARCHEXP = /usr/local/lib/x86_64-linux-gnu/perl/5.22.1
SO = so
VENDORARCHEXP = /usr/lib/x86_64-linux-gnu/perl5/5.22
VENDORLIBEXP = /usr/share/perl5


# --- MakeMaker constants section:
AR_STATIC_ARGS = cr
DIRFILESEP = /
DFSEP = $(DIRFILESEP)
NAME = LWP
NAME_SYM = LWP
VERSION = 5.834
VERSION_MACRO = VERSION
VERSION_SYM = 5_834
DEFINE_VERSION = -D$(VERSION_MACRO)=\"$(VERSION)\"
XS_VERSION = 5.834
XS_VERSION_MACRO = XS_VERSION
XS_DEFINE_VERSION = -D$(XS_VERSION_MACRO)=\"$(XS_VERSION)\"
INST_ARCHLIB = blib/arch
INST_SCRIPT = blib/script
INST_BIN = blib/bin
INST_LIB = blib/lib
INST_MAN1DIR = blib/man1
INST_MAN3DIR = blib/man3
MAN1EXT = 1p
MAN3EXT = 3pm
INSTALLDIRS = site
DESTDIR = 
PREFIX = /home/fabricio/Downloads/sas/modules
PERLPREFIX = $(PREFIX)
SITEPREFIX = $(PREFIX)
VENDORPREFIX = $(PREFIX)
INSTALLPRIVLIB = /home/fabricio/Downloads/sas/modules/lib
DESTINSTALLPRIVLIB = $(DESTDIR)$(INSTALLPRIVLIB)
INSTALLSITELIB = /home/fabricio/Downloads/sas/modules/lib
DESTINSTALLSITELIB = $(DESTDIR)$(INSTALLSITELIB)
INSTALLVENDORLIB = /home/fabricio/Downloads/sas/modules/lib
DESTINSTALLVENDORLIB = $(DESTDIR)$(INSTALLVENDORLIB)
INSTALLARCHLIB = /home/fabricio/Downloads/sas/modules/lib/x86_64-linux-gnu-thread-multi
DESTINSTALLARCHLIB = $(DESTDIR)$(INSTALLARCHLIB)
INSTALLSITEARCH = /home/fabricio/Downloads/sas/modules/lib/x86_64-linux-gnu-thread-multi
DESTINSTALLSITEARCH = $(DESTDIR)$(INSTALLSITEARCH)
INSTALLVENDORARCH = /home/fabricio/Downloads/sas/modules/lib/x86_64-linux-gnu-thread-multi
DESTINSTALLVENDORARCH = $(DESTDIR)$(INSTALLVENDORARCH)
INSTALLBIN = $(PERLPREFIX)/bin
DESTINSTALLBIN = $(DESTDIR)$(INSTALLBIN)
INSTALLSITEBIN = $(SITEPREFIX)/bin
DESTINSTALLSITEBIN = $(DESTDIR)$(INSTALLSITEBIN)
INSTALLVENDORBIN = $(VENDORPREFIX)/bin
DESTINSTALLVENDORBIN = $(DESTDIR)$(INSTALLVENDORBIN)
INSTALLSCRIPT = $(PERLPREFIX)/bin
DESTINSTALLSCRIPT = $(DESTDIR)$(INSTALLSCRIPT)
INSTALLSITESCRIPT = $(SITEPREFIX)/bin
DESTINSTALLSITESCRIPT = $(DESTDIR)$(INSTALLSITESCRIPT)
INSTALLVENDORSCRIPT = $(VENDORPREFIX)/bin
DESTINSTALLVENDORSCRIPT = $(DESTDIR)$(INSTALLVENDORSCRIPT)
INSTALLMAN1DIR = $(PERLPREFIX)/share/man/man1
DESTINSTALLMAN1DIR = $(DESTDIR)$(INSTALLMAN1DIR)
INSTALLSITEMAN1DIR = $(SITEPREFIX)/man/man1
DESTINSTALLSITEMAN1DIR = $(DESTDIR)$(INSTALLSITEMAN1DIR)
INSTALLVENDORMAN1DIR = $(VENDORPREFIX)/share/man/man1
DESTINSTALLVENDORMAN1DIR = $(DESTDIR)$(INSTALLVENDORMAN1DIR)
INSTALLMAN3DIR = $(PERLPREFIX)/share/man/man3
DESTINSTALLMAN3DIR = $(DESTDIR)$(INSTALLMAN3DIR)
INSTALLSITEMAN3DIR = $(SITEPREFIX)/man/man3
DESTINSTALLSITEMAN3DIR = $(DESTDIR)$(INSTALLSITEMAN3DIR)
INSTALLVENDORMAN3DIR = $(VENDORPREFIX)/share/man/man3
DESTINSTALLVENDORMAN3DIR = $(DESTDIR)$(INSTALLVENDORMAN3DIR)
PERL_LIB = /usr/share/perl/5.22
PERL_ARCHLIB = /usr/lib/x86_64-linux-gnu/perl/5.22
PERL_ARCHLIBDEP = /usr/lib/x86_64-linux-gnu/perl/5.22
LIBPERL_A = libperl.a
FIRST_MAKEFILE = Makefile
MAKEFILE_OLD = Makefile.old
MAKE_APERL_FILE = Makefile.aperl
PERLMAINCC = $(CC)
PERL_INC = /usr/lib/x86_64-linux-gnu/perl/5.22/CORE
PERL_INCDEP = /usr/lib/x86_64-linux-gnu/perl/5.22/CORE
PERL = "/usr/bin/perl"
FULLPERL = "/usr/bin/perl"
ABSPERL = $(PERL)
PERLRUN = $(PERL)
FULLPERLRUN = $(FULLPERL)
ABSPERLRUN = $(ABSPERL)
PERLRUNINST = $(PERLRUN) "-I$(INST_ARCHLIB)" "-I$(INST_LIB)"
FULLPERLRUNINST = $(FULLPERLRUN) "-I$(INST_ARCHLIB)" "-I$(INST_LIB)"
ABSPERLRUNINST = $(ABSPERLRUN) "-I$(INST_ARCHLIB)" "-I$(INST_LIB)"
PERL_CORE = 0
PERM_DIR = 755
PERM_RW = 644
PERM_RWX = 755

MAKEMAKER   = /usr/local/share/perl/5.22.1/ExtUtils/MakeMaker.pm
MM_VERSION  = 7.3
MM_REVISION = 73000

# FULLEXT = Pathname for extension directory (eg Foo/Bar/Oracle).
# BASEEXT = Basename part of FULLEXT. May be just equal FULLEXT. (eg Oracle)
# PARENT_NAME = NAME without BASEEXT and no trailing :: (eg Foo::Bar)
# DLBASE  = Basename part of dynamic library. May be just equal BASEEXT.
MAKE = make
FULLEXT = LWP
BASEEXT = LWP
PARENT_NAME = 
DLBASE = $(BASEEXT)
VERSION_FROM = lib/LWP.pm
OBJECT = 
LDFROM = $(OBJECT)
LINKTYPE = dynamic
BOOTDEP = 

# Handy lists of source code files:
XS_FILES = 
C_FILES  = 
O_FILES  = 
H_FILES  = 
MAN1PODS = 
MAN3PODS = lib/Bundle/LWP.pm \
	lib/File/Listing.pm \
	lib/HTML/Form.pm \
	lib/HTTP/Config.pm \
	lib/HTTP/Cookies.pm \
	lib/HTTP/Cookies/Microsoft.pm \
	lib/HTTP/Cookies/Netscape.pm \
	lib/HTTP/Daemon.pm \
	lib/HTTP/Date.pm \
	lib/HTTP/Headers.pm \
	lib/HTTP/Headers/Util.pm \
	lib/HTTP/Message.pm \
	lib/HTTP/Negotiate.pm \
	lib/HTTP/Request.pm \
	lib/HTTP/Request/Common.pm \
	lib/HTTP/Response.pm \
	lib/HTTP/Status.pm \
	lib/LWP.pm \
	lib/LWP/Authen/Ntlm.pm \
	lib/LWP/ConnCache.pm \
	lib/LWP/Debug.pm \
	lib/LWP/MediaTypes.pm \
	lib/LWP/MemberMixin.pm \
	lib/LWP/Protocol.pm \
	lib/LWP/RobotUA.pm \
	lib/LWP/Simple.pm \
	lib/LWP/UserAgent.pm \
	lib/Net/HTTP.pm \
	lib/Net/HTTP/NB.pm \
	lib/WWW/RobotRules.pm \
	lib/WWW/RobotRules/AnyDBM_File.pm \
	lwpcook.pod \
	lwptut.pod

# Where is the Config information that we are using/depend on
CONFIGDEP = $(PERL_ARCHLIBDEP)$(DFSEP)Config.pm $(PERL_INCDEP)$(DFSEP)config.h

# Where to build things
INST_LIBDIR      = $(INST_LIB)
INST_ARCHLIBDIR  = $(INST_ARCHLIB)

INST_AUTODIR     = $(INST_LIB)/auto/$(FULLEXT)
INST_ARCHAUTODIR = $(INST_ARCHLIB)/auto/$(FULLEXT)

INST_STATIC      = 
INST_DYNAMIC     = 
INST_BOOT        = 

# Extra linker info
EXPORT_LIST        = 
PERL_ARCHIVE       = 
PERL_ARCHIVEDEP    = 
PERL_ARCHIVE_AFTER = 


TO_INST_PM = lib/Bundle/LWP.pm \
	lib/File/Listing.pm \
	lib/HTML/Form.pm \
	lib/HTTP/Config.pm \
	lib/HTTP/Cookies.pm \
	lib/HTTP/Cookies/Microsoft.pm \
	lib/HTTP/Cookies/Netscape.pm \
	lib/HTTP/Daemon.pm \
	lib/HTTP/Date.pm \
	lib/HTTP/Headers.pm \
	lib/HTTP/Headers/Auth.pm \
	lib/HTTP/Headers/ETag.pm \
	lib/HTTP/Headers/Util.pm \
	lib/HTTP/Message.pm \
	lib/HTTP/Negotiate.pm \
	lib/HTTP/Request.pm \
	lib/HTTP/Request/Common.pm \
	lib/HTTP/Response.pm \
	lib/HTTP/Status.pm \
	lib/LWP.pm \
	lib/LWP/Authen/Basic.pm \
	lib/LWP/Authen/Digest.pm \
	lib/LWP/Authen/Ntlm.pm \
	lib/LWP/ConnCache.pm \
	lib/LWP/Debug.pm \
	lib/LWP/DebugFile.pm \
	lib/LWP/MediaTypes.pm \
	lib/LWP/MemberMixin.pm \
	lib/LWP/Protocol.pm \
	lib/LWP/Protocol/GHTTP.pm \
	lib/LWP/Protocol/cpan.pm \
	lib/LWP/Protocol/data.pm \
	lib/LWP/Protocol/file.pm \
	lib/LWP/Protocol/ftp.pm \
	lib/LWP/Protocol/gopher.pm \
	lib/LWP/Protocol/http.pm \
	lib/LWP/Protocol/http10.pm \
	lib/LWP/Protocol/https.pm \
	lib/LWP/Protocol/https10.pm \
	lib/LWP/Protocol/loopback.pm \
	lib/LWP/Protocol/mailto.pm \
	lib/LWP/Protocol/nntp.pm \
	lib/LWP/Protocol/nogo.pm \
	lib/LWP/RobotUA.pm \
	lib/LWP/Simple.pm \
	lib/LWP/UserAgent.pm \
	lib/LWP/media.types \
	lib/Net/HTTP.pm \
	lib/Net/HTTP/Methods.pm \
	lib/Net/HTTP/NB.pm \
	lib/Net/HTTPS.pm \
	lib/WWW/RobotRules.pm \
	lib/WWW/RobotRules/AnyDBM_File.pm \
	lwpcook.pod \
	lwptut.pod


# --- MakeMaker platform_constants section:
MM_Unix_VERSION = 7.3
PERL_MALLOC_DEF = -DPERL_EXTMALLOC_DEF -Dmalloc=Perl_malloc -Dfree=Perl_mfree -Drealloc=Perl_realloc -Dcalloc=Perl_calloc


# --- MakeMaker tool_autosplit section:
# Usage: $(AUTOSPLITFILE) FileToSplit AutoDirToSplitInto
AUTOSPLITFILE = $(ABSPERLRUN)  -e 'use AutoSplit;  autosplit($$$$ARGV[0], $$$$ARGV[1], 0, 1, 1)' --



# --- MakeMaker tool_xsubpp section:


# --- MakeMaker tools_other section:
SHELL = /bin/sh
CHMOD = chmod
CP = cp
MV = mv
NOOP = $(TRUE)
NOECHO = @
RM_F = rm -f
RM_RF = rm -rf
TEST_F = test -f
TOUCH = touch
UMASK_NULL = umask 0
DEV_NULL = > /dev/null 2>&1
MKPATH = $(ABSPERLRUN) -MExtUtils::Command -e 'mkpath' --
EQUALIZE_TIMESTAMP = $(ABSPERLRUN) -MExtUtils::Command -e 'eqtime' --
FALSE = false
TRUE = true
ECHO = echo
ECHO_N = echo -n
UNINST = 0
VERBINST = 0
MOD_INSTALL = $(ABSPERLRUN) -MExtUtils::Install -e 'install([ from_to => {@ARGV}, verbose => '\''$(VERBINST)'\'', uninstall_shadows => '\''$(UNINST)'\'', dir_mode => '\''$(PERM_DIR)'\'' ]);' --
DOC_INSTALL = $(ABSPERLRUN) -MExtUtils::Command::MM -e 'perllocal_install' --
UNINSTALL = $(ABSPERLRUN) -MExtUtils::Command::MM -e 'uninstall' --
WARN_IF_OLD_PACKLIST = $(ABSPERLRUN) -MExtUtils::Command::MM -e 'warn_if_old_packlist' --
MACROSTART = 
MACROEND = 
USEMAKEFILE = -f
FIXIN = $(ABSPERLRUN) -MExtUtils::MY -e 'MY->fixin(shift)' --
CP_NONEMPTY = $(ABSPERLRUN) -MExtUtils::Command::MM -e 'cp_nonempty' --


# --- MakeMaker makemakerdflt section:
makemakerdflt : all
	$(NOECHO) $(NOOP)


# --- MakeMaker dist section:
TAR = tar
TARFLAGS = cvf
ZIP = zip
ZIPFLAGS = -r
COMPRESS = gzip --best
SUFFIX = .gz
SHAR = shar
PREOP = $(NOECHO) $(NOOP)
POSTOP = $(NOECHO) $(NOOP)
TO_UNIX = $(NOECHO) $(NOOP)
CI = ci -u
RCS_LABEL = rcs -Nv$(VERSION_SYM): -q
DIST_CP = best
DIST_DEFAULT = tardist
DISTNAME = libwww-perl
DISTVNAME = libwww-perl-5.834


# --- MakeMaker macro section:


# --- MakeMaker depend section:


# --- MakeMaker cflags section:


# --- MakeMaker const_loadlibs section:


# --- MakeMaker const_cccmd section:


# --- MakeMaker post_constants section:


# --- MakeMaker pasthru section:

PASTHRU = LIB="$(LIB)"\
	LIBPERL_A="$(LIBPERL_A)"\
	LINKTYPE="$(LINKTYPE)"\
	PREFIX="$(PREFIX)"\
	PASTHRU_DEFINE='$(DEFINE) $(PASTHRU_DEFINE)'\
	PASTHRU_INC='$(INC) $(PASTHRU_INC)'


# --- MakeMaker special_targets section:
.SUFFIXES : .xs .c .C .cpp .i .s .cxx .cc $(OBJ_EXT)

.PHONY: all config static dynamic test linkext manifest blibdirs clean realclean disttest distdir pure_all subdirs clean_subdirs makemakerdflt manifypods realclean_subdirs subdirs_dynamic subdirs_pure_nolink subdirs_static subdirs-test_dynamic subdirs-test_static test_dynamic test_static



# --- MakeMaker c_o section:


# --- MakeMaker xs_c section:


# --- MakeMaker xs_o section:


# --- MakeMaker top_targets section:
all :: pure_all manifypods
	$(NOECHO) $(NOOP)

pure_all :: config pm_to_blib subdirs linkext
	$(NOECHO) $(NOOP)

	$(NOECHO) $(NOOP)

subdirs :: $(MYEXTLIB)
	$(NOECHO) $(NOOP)

config :: $(FIRST_MAKEFILE) blibdirs
	$(NOECHO) $(NOOP)

help :
	perldoc ExtUtils::MakeMaker


# --- MakeMaker blibdirs section:
blibdirs : $(INST_LIBDIR)$(DFSEP).exists $(INST_ARCHLIB)$(DFSEP).exists $(INST_AUTODIR)$(DFSEP).exists $(INST_ARCHAUTODIR)$(DFSEP).exists $(INST_BIN)$(DFSEP).exists $(INST_SCRIPT)$(DFSEP).exists $(INST_MAN1DIR)$(DFSEP).exists $(INST_MAN3DIR)$(DFSEP).exists
	$(NOECHO) $(NOOP)

# Backwards compat with 6.18 through 6.25
blibdirs.ts : blibdirs
	$(NOECHO) $(NOOP)

$(INST_LIBDIR)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_LIBDIR)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_LIBDIR)
	$(NOECHO) $(TOUCH) $(INST_LIBDIR)$(DFSEP).exists

$(INST_ARCHLIB)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_ARCHLIB)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_ARCHLIB)
	$(NOECHO) $(TOUCH) $(INST_ARCHLIB)$(DFSEP).exists

$(INST_AUTODIR)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_AUTODIR)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_AUTODIR)
	$(NOECHO) $(TOUCH) $(INST_AUTODIR)$(DFSEP).exists

$(INST_ARCHAUTODIR)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_ARCHAUTODIR)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_ARCHAUTODIR)
	$(NOECHO) $(TOUCH) $(INST_ARCHAUTODIR)$(DFSEP).exists

$(INST_BIN)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_BIN)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_BIN)
	$(NOECHO) $(TOUCH) $(INST_BIN)$(DFSEP).exists

$(INST_SCRIPT)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_SCRIPT)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_SCRIPT)
	$(NOECHO) $(TOUCH) $(INST_SCRIPT)$(DFSEP).exists

$(INST_MAN1DIR)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_MAN1DIR)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_MAN1DIR)
	$(NOECHO) $(TOUCH) $(INST_MAN1DIR)$(DFSEP).exists

$(INST_MAN3DIR)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_MAN3DIR)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_MAN3DIR)
	$(NOECHO) $(TOUCH) $(INST_MAN3DIR)$(DFSEP).exists



# --- MakeMaker linkext section:

linkext :: dynamic
	$(NOECHO) $(NOOP)


# --- MakeMaker dlsyms section:


# --- MakeMaker dynamic_bs section:

BOOTSTRAP =


# --- MakeMaker dynamic section:

dynamic :: $(FIRST_MAKEFILE) config $(INST_BOOT) $(INST_DYNAMIC)
	$(NOECHO) $(NOOP)


# --- MakeMaker dynamic_lib section:


# --- MakeMaker static section:

## $(INST_PM) has been moved to the all: target.
## It remains here for awhile to allow for old usage: "make static"
static :: $(FIRST_MAKEFILE) $(INST_STATIC)
	$(NOECHO) $(NOOP)


# --- MakeMaker static_lib section:


# --- MakeMaker manifypods section:

POD2MAN_EXE = $(PERLRUN) "-MExtUtils::Command::MM" -e pod2man "--"
POD2MAN = $(POD2MAN_EXE)


manifypods : pure_all config  \
	lib/Bundle/LWP.pm \
	lib/File/Listing.pm \
	lib/HTML/Form.pm \
	lib/HTTP/Config.pm \
	lib/HTTP/Cookies.pm \
	lib/HTTP/Cookies/Microsoft.pm \
	lib/HTTP/Cookies/Netscape.pm \
	lib/HTTP/Daemon.pm \
	lib/HTTP/Date.pm \
	lib/HTTP/Headers.pm \
	lib/HTTP/Headers/Util.pm \
	lib/HTTP/Message.pm \
	lib/HTTP/Negotiate.pm \
	lib/HTTP/Request.pm \
	lib/HTTP/Request/Common.pm \
	lib/HTTP/Response.pm \
	lib/HTTP/Status.pm \
	lib/LWP.pm \
	lib/LWP/Authen/Ntlm.pm \
	lib/LWP/ConnCache.pm \
	lib/LWP/Debug.pm \
	lib/LWP/MediaTypes.pm \
	lib/LWP/MemberMixin.pm \
	lib/LWP/Protocol.pm \
	lib/LWP/RobotUA.pm \
	lib/LWP/Simple.pm \
	lib/LWP/UserAgent.pm \
	lib/Net/HTTP.pm \
	lib/Net/HTTP/NB.pm \
	lib/WWW/RobotRules.pm \
	lib/WWW/RobotRules/AnyDBM_File.pm \
	lwpcook.pod \
	lwptut.pod
	$(NOECHO) $(POD2MAN) --section=3 --perm_rw=$(PERM_RW) -u \
	  lib/Bundle/LWP.pm $(INST_MAN3DIR)/Bundle::LWP.$(MAN3EXT) \
	  lib/File/Listing.pm $(INST_MAN3DIR)/File::Listing.$(MAN3EXT) \
	  lib/HTML/Form.pm $(INST_MAN3DIR)/HTML::Form.$(MAN3EXT) \
	  lib/HTTP/Config.pm $(INST_MAN3DIR)/HTTP::Config.$(MAN3EXT) \
	  lib/HTTP/Cookies.pm $(INST_MAN3DIR)/HTTP::Cookies.$(MAN3EXT) \
	  lib/HTTP/Cookies/Microsoft.pm $(INST_MAN3DIR)/HTTP::Cookies::Microsoft.$(MAN3EXT) \
	  lib/HTTP/Cookies/Netscape.pm $(INST_MAN3DIR)/HTTP::Cookies::Netscape.$(MAN3EXT) \
	  lib/HTTP/Daemon.pm $(INST_MAN3DIR)/HTTP::Daemon.$(MAN3EXT) \
	  lib/HTTP/Date.pm $(INST_MAN3DIR)/HTTP::Date.$(MAN3EXT) \
	  lib/HTTP/Headers.pm $(INST_MAN3DIR)/HTTP::Headers.$(MAN3EXT) \
	  lib/HTTP/Headers/Util.pm $(INST_MAN3DIR)/HTTP::Headers::Util.$(MAN3EXT) \
	  lib/HTTP/Message.pm $(INST_MAN3DIR)/HTTP::Message.$(MAN3EXT) \
	  lib/HTTP/Negotiate.pm $(INST_MAN3DIR)/HTTP::Negotiate.$(MAN3EXT) \
	  lib/HTTP/Request.pm $(INST_MAN3DIR)/HTTP::Request.$(MAN3EXT) \
	  lib/HTTP/Request/Common.pm $(INST_MAN3DIR)/HTTP::Request::Common.$(MAN3EXT) \
	  lib/HTTP/Response.pm $(INST_MAN3DIR)/HTTP::Response.$(MAN3EXT) \
	  lib/HTTP/Status.pm $(INST_MAN3DIR)/HTTP::Status.$(MAN3EXT) \
	  lib/LWP.pm $(INST_MAN3DIR)/LWP.$(MAN3EXT) \
	  lib/LWP/Authen/Ntlm.pm $(INST_MAN3DIR)/LWP::Authen::Ntlm.$(MAN3EXT) \
	  lib/LWP/ConnCache.pm $(INST_MAN3DIR)/LWP::ConnCache.$(MAN3EXT) \
	  lib/LWP/Debug.pm $(INST_MAN3DIR)/LWP::Debug.$(MAN3EXT) \
	  lib/LWP/MediaTypes.pm $(INST_MAN3DIR)/LWP::MediaTypes.$(MAN3EXT) \
	  lib/LWP/MemberMixin.pm $(INST_MAN3DIR)/LWP::MemberMixin.$(MAN3EXT) \
	  lib/LWP/Protocol.pm $(INST_MAN3DIR)/LWP::Protocol.$(MAN3EXT) \
	  lib/LWP/RobotUA.pm $(INST_MAN3DIR)/LWP::RobotUA.$(MAN3EXT) \
	  lib/LWP/Simple.pm $(INST_MAN3DIR)/LWP::Simple.$(MAN3EXT) \
	  lib/LWP/UserAgent.pm $(INST_MAN3DIR)/LWP::UserAgent.$(MAN3EXT) \
	  lib/Net/HTTP.pm $(INST_MAN3DIR)/Net::HTTP.$(MAN3EXT) \
	  lib/Net/HTTP/NB.pm $(INST_MAN3DIR)/Net::HTTP::NB.$(MAN3EXT) \
	  lib/WWW/RobotRules.pm $(INST_MAN3DIR)/WWW::RobotRules.$(MAN3EXT) \
	  lib/WWW/RobotRules/AnyDBM_File.pm $(INST_MAN3DIR)/WWW::RobotRules::AnyDBM_File.$(MAN3EXT) \
	  lwpcook.pod $(INST_MAN3DIR)/lwpcook.$(MAN3EXT) \
	  lwptut.pod $(INST_MAN3DIR)/lwptut.$(MAN3EXT) 




# --- MakeMaker processPL section:


# --- MakeMaker installbin section:


# --- MakeMaker subdirs section:

# none

# --- MakeMaker clean_subdirs section:
clean_subdirs :
	$(NOECHO) $(NOOP)


# --- MakeMaker clean section:

# Delete temporary files but do not touch installed files. We don't delete
# the Makefile here so a later make realclean still has a makefile to use.

clean :: clean_subdirs
	- $(RM_F) \
	  $(BASEEXT).bso $(BASEEXT).def \
	  $(BASEEXT).exp $(BASEEXT).x \
	  $(BOOTSTRAP) $(INST_ARCHAUTODIR)/extralibs.all \
	  $(INST_ARCHAUTODIR)/extralibs.ld $(MAKE_APERL_FILE) \
	  *$(LIB_EXT) *$(OBJ_EXT) \
	  *perl.core MYMETA.json \
	  MYMETA.yml blibdirs.ts \
	  core core.*perl.*.? \
	  core.[0-9] core.[0-9][0-9] \
	  core.[0-9][0-9][0-9] core.[0-9][0-9][0-9][0-9] \
	  core.[0-9][0-9][0-9][0-9][0-9] lib$(BASEEXT).def \
	  mon.out perl \
	  perl$(EXE_EXT) perl.exe \
	  perlmain.c pm_to_blib \
	  pm_to_blib.ts so_locations \
	  tmon.out 
	- $(RM_RF) \
	  blib 
	  $(NOECHO) $(RM_F) $(MAKEFILE_OLD)
	- $(MV) $(FIRST_MAKEFILE) $(MAKEFILE_OLD) $(DEV_NULL)


# --- MakeMaker realclean_subdirs section:
# so clean is forced to complete before realclean_subdirs runs
realclean_subdirs : clean
	$(NOECHO) $(NOOP)


# --- MakeMaker realclean section:
# Delete temporary files (via clean) and also delete dist files
realclean purge :: realclean_subdirs
	- $(RM_F) \
	  $(FIRST_MAKEFILE) $(MAKEFILE_OLD) 
	- $(RM_RF) \
	  $(DISTVNAME) 


# --- MakeMaker metafile section:
metafile : create_distdir
	$(NOECHO) $(ECHO) Generating META.yml
	$(NOECHO) $(ECHO) '---' > META_new.yml
	$(NOECHO) $(ECHO) 'abstract: '\''The World-Wide Web library for Perl'\''' >> META_new.yml
	$(NOECHO) $(ECHO) 'author:' >> META_new.yml
	$(NOECHO) $(ECHO) '  - '\''Gisle Aas <gisle@activestate.com>'\''' >> META_new.yml
	$(NOECHO) $(ECHO) 'build_requires:' >> META_new.yml
	$(NOECHO) $(ECHO) '  ExtUtils::MakeMaker: '\''0'\''' >> META_new.yml
	$(NOECHO) $(ECHO) 'configure_requires:' >> META_new.yml
	$(NOECHO) $(ECHO) '  ExtUtils::MakeMaker: '\''0'\''' >> META_new.yml
	$(NOECHO) $(ECHO) 'dynamic_config: 1' >> META_new.yml
	$(NOECHO) $(ECHO) 'generated_by: '\''ExtUtils::MakeMaker version 7.3, CPAN::Meta::Converter version 2.150010'\''' >> META_new.yml
	$(NOECHO) $(ECHO) 'license: perl' >> META_new.yml
	$(NOECHO) $(ECHO) 'meta-spec:' >> META_new.yml
	$(NOECHO) $(ECHO) '  url: http://module-build.sourceforge.net/META-spec-v1.4.html' >> META_new.yml
	$(NOECHO) $(ECHO) '  version: '\''1.4'\''' >> META_new.yml
	$(NOECHO) $(ECHO) 'name: libwww-perl' >> META_new.yml
	$(NOECHO) $(ECHO) 'no_index:' >> META_new.yml
	$(NOECHO) $(ECHO) '  directory:' >> META_new.yml
	$(NOECHO) $(ECHO) '    - t' >> META_new.yml
	$(NOECHO) $(ECHO) '    - inc' >> META_new.yml
	$(NOECHO) $(ECHO) 'recommends:' >> META_new.yml
	$(NOECHO) $(ECHO) '  Crypt::SSLeay: '\''0'\''' >> META_new.yml
	$(NOECHO) $(ECHO) 'requires:' >> META_new.yml
	$(NOECHO) $(ECHO) '  Compress::Raw::Zlib: '\''0'\''' >> META_new.yml
	$(NOECHO) $(ECHO) '  Digest::MD5: '\''0'\''' >> META_new.yml
	$(NOECHO) $(ECHO) '  HTML::Parser: '\''3.33'\''' >> META_new.yml
	$(NOECHO) $(ECHO) '  HTML::Tagset: '\''0'\''' >> META_new.yml
	$(NOECHO) $(ECHO) '  IO::Compress::Deflate: '\''0'\''' >> META_new.yml
	$(NOECHO) $(ECHO) '  IO::Compress::Gzip: '\''0'\''' >> META_new.yml
	$(NOECHO) $(ECHO) '  IO::Uncompress::Gunzip: '\''0'\''' >> META_new.yml
	$(NOECHO) $(ECHO) '  IO::Uncompress::Inflate: '\''0'\''' >> META_new.yml
	$(NOECHO) $(ECHO) '  IO::Uncompress::RawInflate: '\''0'\''' >> META_new.yml
	$(NOECHO) $(ECHO) '  MIME::Base64: '\''2.1'\''' >> META_new.yml
	$(NOECHO) $(ECHO) '  Net::FTP: '\''2.58'\''' >> META_new.yml
	$(NOECHO) $(ECHO) '  URI: '\''1.10'\''' >> META_new.yml
	$(NOECHO) $(ECHO) '  perl: '\''5.006'\''' >> META_new.yml
	$(NOECHO) $(ECHO) 'resources:' >> META_new.yml
	$(NOECHO) $(ECHO) '  MailingList: mailto:libwww@perl.org' >> META_new.yml
	$(NOECHO) $(ECHO) '  repository: http://gitorious.org/projects/libwww-perl' >> META_new.yml
	$(NOECHO) $(ECHO) 'version: '\''5.834'\''' >> META_new.yml
	$(NOECHO) $(ECHO) 'x_serialization_backend: '\''CPAN::Meta::YAML version 0.018'\''' >> META_new.yml
	-$(NOECHO) $(MV) META_new.yml $(DISTVNAME)/META.yml
	$(NOECHO) $(ECHO) Generating META.json
	$(NOECHO) $(ECHO) '{' > META_new.json
	$(NOECHO) $(ECHO) '   "abstract" : "The World-Wide Web library for Perl",' >> META_new.json
	$(NOECHO) $(ECHO) '   "author" : [' >> META_new.json
	$(NOECHO) $(ECHO) '      "Gisle Aas <gisle@activestate.com>"' >> META_new.json
	$(NOECHO) $(ECHO) '   ],' >> META_new.json
	$(NOECHO) $(ECHO) '   "dynamic_config" : 1,' >> META_new.json
	$(NOECHO) $(ECHO) '   "generated_by" : "ExtUtils::MakeMaker version 7.3, CPAN::Meta::Converter version 2.150010",' >> META_new.json
	$(NOECHO) $(ECHO) '   "license" : [' >> META_new.json
	$(NOECHO) $(ECHO) '      "perl_5"' >> META_new.json
	$(NOECHO) $(ECHO) '   ],' >> META_new.json
	$(NOECHO) $(ECHO) '   "meta-spec" : {' >> META_new.json
	$(NOECHO) $(ECHO) '      "url" : "http://search.cpan.org/perldoc?CPAN::Meta::Spec",' >> META_new.json
	$(NOECHO) $(ECHO) '      "version" : 2' >> META_new.json
	$(NOECHO) $(ECHO) '   },' >> META_new.json
	$(NOECHO) $(ECHO) '   "name" : "libwww-perl",' >> META_new.json
	$(NOECHO) $(ECHO) '   "no_index" : {' >> META_new.json
	$(NOECHO) $(ECHO) '      "directory" : [' >> META_new.json
	$(NOECHO) $(ECHO) '         "t",' >> META_new.json
	$(NOECHO) $(ECHO) '         "inc"' >> META_new.json
	$(NOECHO) $(ECHO) '      ]' >> META_new.json
	$(NOECHO) $(ECHO) '   },' >> META_new.json
	$(NOECHO) $(ECHO) '   "prereqs" : {' >> META_new.json
	$(NOECHO) $(ECHO) '      "build" : {' >> META_new.json
	$(NOECHO) $(ECHO) '         "requires" : {' >> META_new.json
	$(NOECHO) $(ECHO) '            "ExtUtils::MakeMaker" : "0"' >> META_new.json
	$(NOECHO) $(ECHO) '         }' >> META_new.json
	$(NOECHO) $(ECHO) '      },' >> META_new.json
	$(NOECHO) $(ECHO) '      "configure" : {' >> META_new.json
	$(NOECHO) $(ECHO) '         "requires" : {' >> META_new.json
	$(NOECHO) $(ECHO) '            "ExtUtils::MakeMaker" : "0"' >> META_new.json
	$(NOECHO) $(ECHO) '         }' >> META_new.json
	$(NOECHO) $(ECHO) '      },' >> META_new.json
	$(NOECHO) $(ECHO) '      "runtime" : {' >> META_new.json
	$(NOECHO) $(ECHO) '         "recommends" : {' >> META_new.json
	$(NOECHO) $(ECHO) '            "Crypt::SSLeay" : "0"' >> META_new.json
	$(NOECHO) $(ECHO) '         },' >> META_new.json
	$(NOECHO) $(ECHO) '         "requires" : {' >> META_new.json
	$(NOECHO) $(ECHO) '            "Compress::Raw::Zlib" : "0",' >> META_new.json
	$(NOECHO) $(ECHO) '            "Digest::MD5" : "0",' >> META_new.json
	$(NOECHO) $(ECHO) '            "HTML::Parser" : "3.33",' >> META_new.json
	$(NOECHO) $(ECHO) '            "HTML::Tagset" : "0",' >> META_new.json
	$(NOECHO) $(ECHO) '            "IO::Compress::Deflate" : "0",' >> META_new.json
	$(NOECHO) $(ECHO) '            "IO::Compress::Gzip" : "0",' >> META_new.json
	$(NOECHO) $(ECHO) '            "IO::Uncompress::Gunzip" : "0",' >> META_new.json
	$(NOECHO) $(ECHO) '            "IO::Uncompress::Inflate" : "0",' >> META_new.json
	$(NOECHO) $(ECHO) '            "IO::Uncompress::RawInflate" : "0",' >> META_new.json
	$(NOECHO) $(ECHO) '            "MIME::Base64" : "2.1",' >> META_new.json
	$(NOECHO) $(ECHO) '            "Net::FTP" : "2.58",' >> META_new.json
	$(NOECHO) $(ECHO) '            "URI" : "1.10",' >> META_new.json
	$(NOECHO) $(ECHO) '            "perl" : "5.006"' >> META_new.json
	$(NOECHO) $(ECHO) '         }' >> META_new.json
	$(NOECHO) $(ECHO) '      }' >> META_new.json
	$(NOECHO) $(ECHO) '   },' >> META_new.json
	$(NOECHO) $(ECHO) '   "release_status" : "stable",' >> META_new.json
	$(NOECHO) $(ECHO) '   "resources" : {' >> META_new.json
	$(NOECHO) $(ECHO) '      "repository" : {' >> META_new.json
	$(NOECHO) $(ECHO) '         "url" : "http://gitorious.org/projects/libwww-perl"' >> META_new.json
	$(NOECHO) $(ECHO) '      },' >> META_new.json
	$(NOECHO) $(ECHO) '      "x_MailingList" : "mailto:libwww@perl.org"' >> META_new.json
	$(NOECHO) $(ECHO) '   },' >> META_new.json
	$(NOECHO) $(ECHO) '   "version" : "5.834",' >> META_new.json
	$(NOECHO) $(ECHO) '   "x_serialization_backend" : "JSON::PP version 2.94"' >> META_new.json
	$(NOECHO) $(ECHO) '}' >> META_new.json
	-$(NOECHO) $(MV) META_new.json $(DISTVNAME)/META.json


# --- MakeMaker signature section:
signature :
	cpansign -s


# --- MakeMaker dist_basics section:
distclean :: realclean distcheck
	$(NOECHO) $(NOOP)

distcheck :
	$(PERLRUN) "-MExtUtils::Manifest=fullcheck" -e fullcheck

skipcheck :
	$(PERLRUN) "-MExtUtils::Manifest=skipcheck" -e skipcheck

manifest :
	$(PERLRUN) "-MExtUtils::Manifest=mkmanifest" -e mkmanifest

veryclean : realclean
	$(RM_F) *~ */*~ *.orig */*.orig *.bak */*.bak *.old */*.old



# --- MakeMaker dist_core section:

dist : $(DIST_DEFAULT) $(FIRST_MAKEFILE)
	$(NOECHO) $(ABSPERLRUN) -l -e 'print '\''Warning: Makefile possibly out of date with $(VERSION_FROM)'\''' \
	  -e '    if -e '\''$(VERSION_FROM)'\'' and -M '\''$(VERSION_FROM)'\'' < -M '\''$(FIRST_MAKEFILE)'\'';' --

tardist : $(DISTVNAME).tar$(SUFFIX)
	$(NOECHO) $(NOOP)

uutardist : $(DISTVNAME).tar$(SUFFIX)
	uuencode $(DISTVNAME).tar$(SUFFIX) $(DISTVNAME).tar$(SUFFIX) > $(DISTVNAME).tar$(SUFFIX)_uu
	$(NOECHO) $(ECHO) 'Created $(DISTVNAME).tar$(SUFFIX)_uu'

$(DISTVNAME).tar$(SUFFIX) : distdir
	$(PREOP)
	$(TO_UNIX)
	$(TAR) $(TARFLAGS) $(DISTVNAME).tar $(DISTVNAME)
	$(RM_RF) $(DISTVNAME)
	$(COMPRESS) $(DISTVNAME).tar
	$(NOECHO) $(ECHO) 'Created $(DISTVNAME).tar$(SUFFIX)'
	$(POSTOP)

zipdist : $(DISTVNAME).zip
	$(NOECHO) $(NOOP)

$(DISTVNAME).zip : distdir
	$(PREOP)
	$(ZIP) $(ZIPFLAGS) $(DISTVNAME).zip $(DISTVNAME)
	$(RM_RF) $(DISTVNAME)
	$(NOECHO) $(ECHO) 'Created $(DISTVNAME).zip'
	$(POSTOP)

shdist : distdir
	$(PREOP)
	$(SHAR) $(DISTVNAME) > $(DISTVNAME).shar
	$(RM_RF) $(DISTVNAME)
	$(NOECHO) $(ECHO) 'Created $(DISTVNAME).shar'
	$(POSTOP)


# --- MakeMaker distdir section:
create_distdir :
	$(RM_RF) $(DISTVNAME)
	$(PERLRUN) "-MExtUtils::Manifest=manicopy,maniread" \
		-e "manicopy(maniread(),'$(DISTVNAME)', '$(DIST_CP)');"

distdir : create_distdir distmeta 
	$(NOECHO) $(NOOP)



# --- MakeMaker dist_test section:
disttest : distdir
	cd $(DISTVNAME) && $(ABSPERLRUN) Makefile.PL "PREFIX=/home/fabricio/Downloads/sas/modules" "LIB=/home/fabricio/Downloads/sas/modules/lib"
	cd $(DISTVNAME) && $(MAKE) $(PASTHRU)
	cd $(DISTVNAME) && $(MAKE) test $(PASTHRU)



# --- MakeMaker dist_ci section:
ci :
	$(ABSPERLRUN) -MExtUtils::Manifest=maniread -e '@all = sort keys %{ maniread() };' \
	  -e 'print(qq{Executing $(CI) @all\n});' \
	  -e 'system(qq{$(CI) @all}) == 0 or die $$!;' \
	  -e 'print(qq{Executing $(RCS_LABEL) ...\n});' \
	  -e 'system(qq{$(RCS_LABEL) @all}) == 0 or die $$!;' --


# --- MakeMaker distmeta section:
distmeta : create_distdir metafile
	$(NOECHO) cd $(DISTVNAME) && $(ABSPERLRUN) -MExtUtils::Manifest=maniadd -e 'exit unless -e q{META.yml};' \
	  -e 'eval { maniadd({q{META.yml} => q{Module YAML meta-data (added by MakeMaker)}}) }' \
	  -e '    or die "Could not add META.yml to MANIFEST: $${'\''@'\''}"' --
	$(NOECHO) cd $(DISTVNAME) && $(ABSPERLRUN) -MExtUtils::Manifest=maniadd -e 'exit unless -f q{META.json};' \
	  -e 'eval { maniadd({q{META.json} => q{Module JSON meta-data (added by MakeMaker)}}) }' \
	  -e '    or die "Could not add META.json to MANIFEST: $${'\''@'\''}"' --



# --- MakeMaker distsignature section:
distsignature : distmeta
	$(NOECHO) cd $(DISTVNAME) && $(ABSPERLRUN) -MExtUtils::Manifest=maniadd -e 'eval { maniadd({q{SIGNATURE} => q{Public-key signature (added by MakeMaker)}}) }' \
	  -e '    or die "Could not add SIGNATURE to MANIFEST: $${'\''@'\''}"' --
	$(NOECHO) cd $(DISTVNAME) && $(TOUCH) SIGNATURE
	cd $(DISTVNAME) && cpansign -s



# --- MakeMaker install section:

install :: pure_install doc_install
	$(NOECHO) $(NOOP)

install_perl :: pure_perl_install doc_perl_install
	$(NOECHO) $(NOOP)

install_site :: pure_site_install doc_site_install
	$(NOECHO) $(NOOP)

install_vendor :: pure_vendor_install doc_vendor_install
	$(NOECHO) $(NOOP)

pure_install :: pure_$(INSTALLDIRS)_install
	$(NOECHO) $(NOOP)

doc_install :: doc_$(INSTALLDIRS)_install
	$(NOECHO) $(NOOP)

pure__install : pure_site_install
	$(NOECHO) $(ECHO) INSTALLDIRS not defined, defaulting to INSTALLDIRS=site

doc__install : doc_site_install
	$(NOECHO) $(ECHO) INSTALLDIRS not defined, defaulting to INSTALLDIRS=site

pure_perl_install :: all
	$(NOECHO) $(MOD_INSTALL) \
		read "$(PERL_ARCHLIB)/auto/$(FULLEXT)/.packlist" \
		write "$(DESTINSTALLARCHLIB)/auto/$(FULLEXT)/.packlist" \
		"$(INST_LIB)" "$(DESTINSTALLPRIVLIB)" \
		"$(INST_ARCHLIB)" "$(DESTINSTALLARCHLIB)" \
		"$(INST_BIN)" "$(DESTINSTALLBIN)" \
		"$(INST_SCRIPT)" "$(DESTINSTALLSCRIPT)" \
		"$(INST_MAN1DIR)" "$(DESTINSTALLMAN1DIR)" \
		"$(INST_MAN3DIR)" "$(DESTINSTALLMAN3DIR)"
	$(NOECHO) $(WARN_IF_OLD_PACKLIST) \
		"$(SITEARCHEXP)/auto/$(FULLEXT)"


pure_site_install :: all
	$(NOECHO) $(MOD_INSTALL) \
		read "$(SITEARCHEXP)/auto/$(FULLEXT)/.packlist" \
		write "$(DESTINSTALLSITEARCH)/auto/$(FULLEXT)/.packlist" \
		"$(INST_LIB)" "$(DESTINSTALLSITELIB)" \
		"$(INST_ARCHLIB)" "$(DESTINSTALLSITEARCH)" \
		"$(INST_BIN)" "$(DESTINSTALLSITEBIN)" \
		"$(INST_SCRIPT)" "$(DESTINSTALLSITESCRIPT)" \
		"$(INST_MAN1DIR)" "$(DESTINSTALLSITEMAN1DIR)" \
		"$(INST_MAN3DIR)" "$(DESTINSTALLSITEMAN3DIR)"
	$(NOECHO) $(WARN_IF_OLD_PACKLIST) \
		"$(PERL_ARCHLIB)/auto/$(FULLEXT)"

pure_vendor_install :: all
	$(NOECHO) $(MOD_INSTALL) \
		read "$(VENDORARCHEXP)/auto/$(FULLEXT)/.packlist" \
		write "$(DESTINSTALLVENDORARCH)/auto/$(FULLEXT)/.packlist" \
		"$(INST_LIB)" "$(DESTINSTALLVENDORLIB)" \
		"$(INST_ARCHLIB)" "$(DESTINSTALLVENDORARCH)" \
		"$(INST_BIN)" "$(DESTINSTALLVENDORBIN)" \
		"$(INST_SCRIPT)" "$(DESTINSTALLVENDORSCRIPT)" \
		"$(INST_MAN1DIR)" "$(DESTINSTALLVENDORMAN1DIR)" \
		"$(INST_MAN3DIR)" "$(DESTINSTALLVENDORMAN3DIR)"


doc_perl_install :: all
	$(NOECHO) $(ECHO) Appending installation info to "$(DESTINSTALLARCHLIB)/perllocal.pod"
	-$(NOECHO) $(MKPATH) "$(DESTINSTALLARCHLIB)"
	-$(NOECHO) $(DOC_INSTALL) \
		"Module" "$(NAME)" \
		"installed into" "$(INSTALLPRIVLIB)" \
		LINKTYPE "$(LINKTYPE)" \
		VERSION "$(VERSION)" \
		EXE_FILES "$(EXE_FILES)" \
		>> "$(DESTINSTALLARCHLIB)/perllocal.pod"

doc_site_install :: all
	$(NOECHO) $(ECHO) Appending installation info to "$(DESTINSTALLARCHLIB)/perllocal.pod"
	-$(NOECHO) $(MKPATH) "$(DESTINSTALLARCHLIB)"
	-$(NOECHO) $(DOC_INSTALL) \
		"Module" "$(NAME)" \
		"installed into" "$(INSTALLSITELIB)" \
		LINKTYPE "$(LINKTYPE)" \
		VERSION "$(VERSION)" \
		EXE_FILES "$(EXE_FILES)" \
		>> "$(DESTINSTALLARCHLIB)/perllocal.pod"

doc_vendor_install :: all
	$(NOECHO) $(ECHO) Appending installation info to "$(DESTINSTALLARCHLIB)/perllocal.pod"
	-$(NOECHO) $(MKPATH) "$(DESTINSTALLARCHLIB)"
	-$(NOECHO) $(DOC_INSTALL) \
		"Module" "$(NAME)" \
		"installed into" "$(INSTALLVENDORLIB)" \
		LINKTYPE "$(LINKTYPE)" \
		VERSION "$(VERSION)" \
		EXE_FILES "$(EXE_FILES)" \
		>> "$(DESTINSTALLARCHLIB)/perllocal.pod"


uninstall :: uninstall_from_$(INSTALLDIRS)dirs
	$(NOECHO) $(NOOP)

uninstall_from_perldirs ::
	$(NOECHO) $(UNINSTALL) "$(PERL_ARCHLIB)/auto/$(FULLEXT)/.packlist"

uninstall_from_sitedirs ::
	$(NOECHO) $(UNINSTALL) "$(SITEARCHEXP)/auto/$(FULLEXT)/.packlist"

uninstall_from_vendordirs ::
	$(NOECHO) $(UNINSTALL) "$(VENDORARCHEXP)/auto/$(FULLEXT)/.packlist"


# --- MakeMaker force section:
# Phony target to force checking subdirectories.
FORCE :
	$(NOECHO) $(NOOP)


# --- MakeMaker perldepend section:


# --- MakeMaker makefile section:
# We take a very conservative approach here, but it's worth it.
# We move Makefile to Makefile.old here to avoid gnu make looping.
$(FIRST_MAKEFILE) : Makefile.PL $(CONFIGDEP)
	$(NOECHO) $(ECHO) "Makefile out-of-date with respect to $?"
	$(NOECHO) $(ECHO) "Cleaning current config before rebuilding Makefile..."
	-$(NOECHO) $(RM_F) $(MAKEFILE_OLD)
	-$(NOECHO) $(MV)   $(FIRST_MAKEFILE) $(MAKEFILE_OLD)
	- $(MAKE) $(USEMAKEFILE) $(MAKEFILE_OLD) clean $(DEV_NULL)
	$(PERLRUN) Makefile.PL "PREFIX=/home/fabricio/Downloads/sas/modules" "LIB=/home/fabricio/Downloads/sas/modules/lib"
	$(NOECHO) $(ECHO) "==> Your Makefile has been rebuilt. <=="
	$(NOECHO) $(ECHO) "==> Please rerun the $(MAKE) command.  <=="
	$(FALSE)



# --- MakeMaker staticmake section:

# --- MakeMaker makeaperl section ---
MAP_TARGET    = perl
FULLPERL      = "/usr/bin/perl"
MAP_PERLINC   = "-Iblib/arch" "-Iblib/lib" "-I/usr/lib/x86_64-linux-gnu/perl/5.22" "-I/usr/share/perl/5.22"

$(MAP_TARGET) :: $(MAKE_APERL_FILE)
	$(MAKE) $(USEMAKEFILE) $(MAKE_APERL_FILE) $@

$(MAKE_APERL_FILE) : static $(FIRST_MAKEFILE) pm_to_blib
	$(NOECHO) $(ECHO) Writing \"$(MAKE_APERL_FILE)\" for this $(MAP_TARGET)
	$(NOECHO) $(PERLRUNINST) \
		Makefile.PL DIR="" \
		MAKEFILE=$(MAKE_APERL_FILE) LINKTYPE=static \
		MAKEAPERL=1 NORECURS=1 CCCDLFLAGS= \
		PREFIX=/home/fabricio/Downloads/sas/modules \
		LIB=/home/fabricio/Downloads/sas/modules/lib


# --- MakeMaker test section:

TEST_VERBOSE=0

test : pure_all
	$(FULLPERL) t/TEST $(TEST_VERBOSE)



# --- MakeMaker ppd section:
# Creates a PPD (Perl Package Description) for a binary distribution.
ppd :
	$(NOECHO) $(ECHO) '<SOFTPKG NAME="libwww-perl" VERSION="5.834">' > libwww-perl.ppd
	$(NOECHO) $(ECHO) '    <ABSTRACT>The World-Wide Web library for Perl</ABSTRACT>' >> libwww-perl.ppd
	$(NOECHO) $(ECHO) '    <AUTHOR>Gisle Aas &lt;gisle@activestate.com&gt;</AUTHOR>' >> libwww-perl.ppd
	$(NOECHO) $(ECHO) '    <IMPLEMENTATION>' >> libwww-perl.ppd
	$(NOECHO) $(ECHO) '        <PERLCORE VERSION="5,006,0,0" />' >> libwww-perl.ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Compress::Raw::Zlib" />' >> libwww-perl.ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Digest::MD5" />' >> libwww-perl.ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="HTML::Parser" VERSION="3.33" />' >> libwww-perl.ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="HTML::Tagset" />' >> libwww-perl.ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="IO::Compress::Deflate" />' >> libwww-perl.ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="IO::Compress::Gzip" />' >> libwww-perl.ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="IO::Uncompress::Gunzip" />' >> libwww-perl.ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="IO::Uncompress::Inflate" />' >> libwww-perl.ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="IO::Uncompress::RawInflate" />' >> libwww-perl.ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="MIME::Base64" VERSION="2.1" />' >> libwww-perl.ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Net::FTP" VERSION="2.58" />' >> libwww-perl.ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="URI::" VERSION="1.10" />' >> libwww-perl.ppd
	$(NOECHO) $(ECHO) '        <ARCHITECTURE NAME="x86_64-linux-gnu-thread-multi-5.22" />' >> libwww-perl.ppd
	$(NOECHO) $(ECHO) '        <CODEBASE HREF="" />' >> libwww-perl.ppd
	$(NOECHO) $(ECHO) '    </IMPLEMENTATION>' >> libwww-perl.ppd
	$(NOECHO) $(ECHO) '</SOFTPKG>' >> libwww-perl.ppd


# --- MakeMaker pm_to_blib section:

pm_to_blib : $(FIRST_MAKEFILE) $(TO_INST_PM)
	$(NOECHO) $(ABSPERLRUN) -MExtUtils::Install -e 'pm_to_blib({@ARGV}, '\''$(INST_LIB)/auto'\'', q[$(PM_FILTER)], '\''$(PERM_DIR)'\'')' -- \
	  'lib/Bundle/LWP.pm' 'blib/lib/Bundle/LWP.pm' \
	  'lib/File/Listing.pm' 'blib/lib/File/Listing.pm' \
	  'lib/HTML/Form.pm' 'blib/lib/HTML/Form.pm' \
	  'lib/HTTP/Config.pm' 'blib/lib/HTTP/Config.pm' \
	  'lib/HTTP/Cookies.pm' 'blib/lib/HTTP/Cookies.pm' \
	  'lib/HTTP/Cookies/Microsoft.pm' 'blib/lib/HTTP/Cookies/Microsoft.pm' \
	  'lib/HTTP/Cookies/Netscape.pm' 'blib/lib/HTTP/Cookies/Netscape.pm' \
	  'lib/HTTP/Daemon.pm' 'blib/lib/HTTP/Daemon.pm' \
	  'lib/HTTP/Date.pm' 'blib/lib/HTTP/Date.pm' \
	  'lib/HTTP/Headers.pm' 'blib/lib/HTTP/Headers.pm' \
	  'lib/HTTP/Headers/Auth.pm' 'blib/lib/HTTP/Headers/Auth.pm' \
	  'lib/HTTP/Headers/ETag.pm' 'blib/lib/HTTP/Headers/ETag.pm' \
	  'lib/HTTP/Headers/Util.pm' 'blib/lib/HTTP/Headers/Util.pm' \
	  'lib/HTTP/Message.pm' 'blib/lib/HTTP/Message.pm' \
	  'lib/HTTP/Negotiate.pm' 'blib/lib/HTTP/Negotiate.pm' \
	  'lib/HTTP/Request.pm' 'blib/lib/HTTP/Request.pm' \
	  'lib/HTTP/Request/Common.pm' 'blib/lib/HTTP/Request/Common.pm' \
	  'lib/HTTP/Response.pm' 'blib/lib/HTTP/Response.pm' \
	  'lib/HTTP/Status.pm' 'blib/lib/HTTP/Status.pm' \
	  'lib/LWP.pm' 'blib/lib/LWP.pm' \
	  'lib/LWP/Authen/Basic.pm' 'blib/lib/LWP/Authen/Basic.pm' \
	  'lib/LWP/Authen/Digest.pm' 'blib/lib/LWP/Authen/Digest.pm' \
	  'lib/LWP/Authen/Ntlm.pm' 'blib/lib/LWP/Authen/Ntlm.pm' \
	  'lib/LWP/ConnCache.pm' 'blib/lib/LWP/ConnCache.pm' \
	  'lib/LWP/Debug.pm' 'blib/lib/LWP/Debug.pm' \
	  'lib/LWP/DebugFile.pm' 'blib/lib/LWP/DebugFile.pm' \
	  'lib/LWP/MediaTypes.pm' 'blib/lib/LWP/MediaTypes.pm' \
	  'lib/LWP/MemberMixin.pm' 'blib/lib/LWP/MemberMixin.pm' \
	  'lib/LWP/Protocol.pm' 'blib/lib/LWP/Protocol.pm' \
	  'lib/LWP/Protocol/GHTTP.pm' 'blib/lib/LWP/Protocol/GHTTP.pm' \
	  'lib/LWP/Protocol/cpan.pm' 'blib/lib/LWP/Protocol/cpan.pm' \
	  'lib/LWP/Protocol/data.pm' 'blib/lib/LWP/Protocol/data.pm' \
	  'lib/LWP/Protocol/file.pm' 'blib/lib/LWP/Protocol/file.pm' \
	  'lib/LWP/Protocol/ftp.pm' 'blib/lib/LWP/Protocol/ftp.pm' \
	  'lib/LWP/Protocol/gopher.pm' 'blib/lib/LWP/Protocol/gopher.pm' \
	  'lib/LWP/Protocol/http.pm' 'blib/lib/LWP/Protocol/http.pm' \
	  'lib/LWP/Protocol/http10.pm' 'blib/lib/LWP/Protocol/http10.pm' \
	  'lib/LWP/Protocol/https.pm' 'blib/lib/LWP/Protocol/https.pm' \
	  'lib/LWP/Protocol/https10.pm' 'blib/lib/LWP/Protocol/https10.pm' \
	  'lib/LWP/Protocol/loopback.pm' 'blib/lib/LWP/Protocol/loopback.pm' \
	  'lib/LWP/Protocol/mailto.pm' 'blib/lib/LWP/Protocol/mailto.pm' \
	  'lib/LWP/Protocol/nntp.pm' 'blib/lib/LWP/Protocol/nntp.pm' \
	  'lib/LWP/Protocol/nogo.pm' 'blib/lib/LWP/Protocol/nogo.pm' \
	  'lib/LWP/RobotUA.pm' 'blib/lib/LWP/RobotUA.pm' \
	  'lib/LWP/Simple.pm' 'blib/lib/LWP/Simple.pm' \
	  'lib/LWP/UserAgent.pm' 'blib/lib/LWP/UserAgent.pm' \
	  'lib/LWP/media.types' 'blib/lib/LWP/media.types' 
	$(NOECHO) $(ABSPERLRUN) -MExtUtils::Install -e 'pm_to_blib({@ARGV}, '\''$(INST_LIB)/auto'\'', q[$(PM_FILTER)], '\''$(PERM_DIR)'\'')' -- \
	  'lib/Net/HTTP.pm' 'blib/lib/Net/HTTP.pm' \
	  'lib/Net/HTTP/Methods.pm' 'blib/lib/Net/HTTP/Methods.pm' \
	  'lib/Net/HTTP/NB.pm' 'blib/lib/Net/HTTP/NB.pm' \
	  'lib/Net/HTTPS.pm' 'blib/lib/Net/HTTPS.pm' \
	  'lib/WWW/RobotRules.pm' 'blib/lib/WWW/RobotRules.pm' \
	  'lib/WWW/RobotRules/AnyDBM_File.pm' 'blib/lib/WWW/RobotRules/AnyDBM_File.pm' \
	  'lwpcook.pod' '$(INST_LIB)/lwpcook.pod' \
	  'lwptut.pod' '$(INST_LIB)/lwptut.pod' 
	$(NOECHO) $(TOUCH) pm_to_blib


# --- MakeMaker selfdocument section:

# here so even if top_targets is overridden, these will still be defined
# gmake will silently still work if any are .PHONY-ed but nmake won't

static ::
	$(NOECHO) $(NOOP)

dynamic ::
	$(NOECHO) $(NOOP)

config ::
	$(NOECHO) $(NOOP)


# --- MakeMaker postamble section:


# End.
