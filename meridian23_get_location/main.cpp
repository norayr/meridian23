#include <QApplication>
#include "loc.h"
#include <iostream>
#include <unistd.h>
#include <sys/types.h>
int main(int a, char** c)
{
pid_t p;
pid_t pp;
p = getpid();
pp = getppid();
std::cout << ("pid") << std::endl;
std::cout << p << std::endl;
std::cout << ("ppid") << std::endl;
std::cout << pp << std::endl;
	QApplication app(a,c);
	locator l;
	return app.exec();
}
