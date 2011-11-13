INSTALL_BIN = install -m 755
INSTALL_DATA = install -m 644
DESTDIR =
prefix  = /usr
bindir  = $(prefix)/bin
mandir  = $(prefix)/share/man/man1

all: jpegexiforient

jpegexiforient: jpegexiforient.c
	$(CC) $(CFLAGS) -o jpegexiforient jpegexiforient.c
clean:
	-rm -f jpegexiforient
install:
	$(INSTALL_BIN)  jpegexiforient    $(DESTDIR)$(bindir)
	$(INSTALL_DATA) jpegexiforient.1  $(DESTDIR)$(mandir)
	$(INSTALL_BIN)  exifautotran      $(DESTDIR)$(bindir)
	$(INSTALL_DATA) exifautotran.1    $(DESTDIR)$(mandir)
