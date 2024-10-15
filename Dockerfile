FROM docker.io/library/debian:stable-slim

ENV STACK_ROOT /stack_cache

RUN mkdir -p $STACK_ROOT

COPY stack-config/config.yaml $STACK_ROOT/config.yaml
COPY stack-config/global-project/stack.yaml $STACK_ROOT/global-project/stack.yaml

RUN apt-get update \
    && apt-get -y install curl \
    && bash -c "curl -sSL https://get.haskellstack.org/ | sh" \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    # Bootstrap GHC
    && stack setup \
    && stack ghc \
            --package QuickCheck \
            --package quickcheck-assertions \
            --package tasty \
            --package tasty-ant-xml \
            --package tasty-hunit \
            --package tasty-quickcheck \
            -- --version \
    # remove profiling support
    && find "/stack_cache" \( -name "*_p.a" -o -name "*.p_hi" \) -type f -delete \
    # remove docs
    && find "/stack_cache/programs" -type d -name "doc" -exec rm -rf {} + \
    # cleanup /tmp
    && rm -rf /tmp/* \
    # Jenkins runs the builds not as root, but with a system dependent user id.
    # Therefore, we allow all users to access the stack cache.
    && chmod -R a+rw $STACK_ROOT
