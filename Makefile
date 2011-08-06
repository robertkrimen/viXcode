.PHONY: test open

test:
	xcodebuild build WARNING_CFLAGS=-Werror -project viXcode.xcodeproj && open test/test.xcodeproj && syslog -w

open:
	open viXcode.xcodeproj
