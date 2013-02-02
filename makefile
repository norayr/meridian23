PC = fpc
LAZARUS  = /home/user/lazarus
#ARCH = x86_64-linux
#ARCH = powerpc-linux
ARCH = arm-linux
#WIDGET = qt
WIDGET = gtk2
OPTS =  -MObjFPC -Scghi -O1 -g -gl -vewnhi -l
#OPTS =  -Cparmv6
#OPTS =  -Cfvfpv2 
#OPTS =  -Cfvfpv3 
OPTS += -Fi$(LAZARUS)/lcl/include
OPTS += -Filib/$(ARCH)
OPTS += -Fl/opt/gnome/lib
OPTS += -Fu$(LAZARUS)/components/lazutils
OPTS += -Fu$(LAZARUS)/lcl
OPTS += -Fu$(LAZARUS)/lcl/forms
OPTS += -Fu$(LAZARUS)/lcl/widgetset
OPTS += -Fu$(LAZARUS)/lcl/interfaces/$(WIDGET)
OPTS += -Fu$(LAZARUS)/lcl/units/$(ARCH)/$(WIDGET)
OPTS += -Fu$(LAZARUS)/lcl/units/$(ARCH)
OPTS += -Fu$(LAZARUS)/components/lazutils/lib/$(ARCH)
OPTS += -Fu$(LAZARUS)/packager/units/$(ARCH)
OPTS += -Fu$(LAZARUS)/lcl/
OPTS += -Fu$(LAZARUS)/lcl/nonwin32
OPTS += -Fu.
OPTS += -FUlib/$(ARCH)
OPTS += -dLCL -dLCL$(WIDGET)

OPTS += -Fuuxmpp -Fuuxmpp/tcpsynapse -Fuuxmpp/tcpsynapse/synapse -Fuopenmap


ALLDIRS = uxmpp uxmpp/tcpsynapse
PROJECT = meridian23
#PROJECT = hello.pas

all:	
	$(PC) $(PROJECT).lpr $(OPTS) 
	strip $(PROJECT)

clean:
	for i in $(ALLDIRS) ; \
	do      ( cd $$i ; rm *.o; rm *.ppu ) ; \
	done

