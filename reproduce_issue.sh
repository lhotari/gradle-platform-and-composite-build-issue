#!/bin/bash -x
( cd library-project; gradle publish; )
( cd platform-project; gradle publish; )
( cd consumer-project; gradle installDist; )

echo -e '\033[0;31mThere should be no library-b.jar in app-a:\033[0m'
find ./consumer-project/app-a/build/install/app-a/lib | grep --color=always -z library-b

echo -e '\033[0;31mThere should be no library-a.jar in app-b:\033[0m'
find ./consumer-project/app-b/build/install/app-b/lib | grep --color=always -z library-a
