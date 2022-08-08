FROM ubuntu:18.04 AS builder

WORKDIR /aosp

RUN apt-get update && \
    apt-get install -y \
         curl \
         python \
         python3 \
         git \
         unzip \
         gpg \
         openjdk-8-jre-headless \
         gcc-6 \
         g++-6 && \
   apt clean && rm -rf /var/lib/apt/lists/*

RUN update-alternatives \
    --install /usr/bin/gcc gcc /usr/bin/gcc-6 60 \
    --slave /usr/bin/g++ g++ /usr/bin/g++-6

RUN mkdir /aosp/bin && \
    curl https://storage.googleapis.com/git-repo-downloads/repo > /aosp/bin/repo && \
    chmod a+x /aosp/bin/repo

# obtain SDK and NDK
RUN curl https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip > /aosp/sdk-tools-linux.zip && \
    unzip /aosp/sdk-tools-linux.zip -d /aosp/sdk && \
    yes | /aosp/sdk/tools/bin/sdkmanager --licenses && \
    /aosp/sdk/tools/bin/sdkmanager "platform-tools" "ndk;20.1.5948944" "platforms;android-32" "build-tools;30.0.0" && \
    ln -s /aosp/sdk/ndk/20.1.5948944 /aosp/sdk/ndk-bundle && \
    rm /aosp/sdk-tools-linux.zip

ENV AOSP_SRC_ROOT=/aosp/src
ENV BUILD_ANDROID_SDK_HOME=/aosp/sdk
ENV REPO_TOOL=/aosp/bin/repo

# First stage stops here so we can attach local sources in dev-builder mode

FROM builder AS builder-dev

ENTRYPOINT ["sh", "/aosp/builder/dev-local/setuplocaluserinvoker.sh"]

