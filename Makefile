.PHONY:

test:
	xcodebuild build WARNING_CFLAGS=-Werror && open testViXcode4/*.xcodeproj && syslog -w
