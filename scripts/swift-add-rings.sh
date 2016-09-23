#!/bin/sh

export SWIFT_STORAGE_ADDRESS=192.168.8.43

export KOLLA_DOCKER_NAMESPACE=openstack-kolla-mitaka-keystone-bug
export KOLLA_BASE_DISTRO=ubuntu
export KOLLA_INSTALL_TYPE=source
export KOLLA_BASE_DISTRO=ubuntu
export KOLLA_VERSION=3.0.0

# Object ring
docker run \
    -v /etc/kolla/config/swift/:/etc/kolla/config/swift/ \
    registry.local:5000/${KOLLA_DOCKER_NAMESPACE}/${KOLLA_BASE_DISTRO}-${KOLLA_INSTALL_TYPE}-swift-base:${KOLLA_VERSION} \
    swift-ring-builder /etc/kolla/config/swift/object.builder create 10 3 1

for i in 0 1 2; do
    docker run \
        -v /etc/kolla/config/swift/:/etc/kolla/config/swift/ \
        registry.local:5000/${KOLLA_DOCKER_NAMESPACE}/${KOLLA_BASE_DISTRO}-${KOLLA_INSTALL_TYPE}-swift-base:${KOLLA_VERSION} swift-ring-builder \
        /etc/kolla/config/swift/object.builder add r1z1-${SWIFT_STORAGE_ADDRESS}:16000/d${i} 1;
done

# Account ring
docker run \
    -v /etc/kolla/config/swift/:/etc/kolla/config/swift/ \
    registry.local:5000/${KOLLA_DOCKER_NAMESPACE}/${KOLLA_BASE_DISTRO}-${KOLLA_INSTALL_TYPE}-swift-base:${KOLLA_VERSION} \
    swift-ring-builder /etc/kolla/config/swift/account.builder create 10 3 1

for i in 0 1 2; do
    docker run \
        -v /etc/kolla/config/swift/:/etc/kolla/config/swift/ \
        registry.local:5000/${KOLLA_DOCKER_NAMESPACE}/${KOLLA_BASE_DISTRO}-${KOLLA_INSTALL_TYPE}-swift-base:${KOLLA_VERSION} swift-ring-builder \
        /etc/kolla/config/swift/account.builder add r1z1-${SWIFT_STORAGE_ADDRESS}:16001/d${i} 1;
done

# Container ring
docker run \
    -v /etc/kolla/config/swift/:/etc/kolla/config/swift/ \
    registry.local:5000/${KOLLA_DOCKER_NAMESPACE}/${KOLLA_BASE_DISTRO}-${KOLLA_INSTALL_TYPE}-swift-base:${KOLLA_VERSION} \
    swift-ring-builder /etc/kolla/config/swift/container.builder create 10 3 1

for i in 0 1 2; do

    docker run \
        -v /etc/kolla/config/swift/:/etc/kolla/config/swift/ \
        registry.local:5000/${KOLLA_DOCKER_NAMESPACE}/${KOLLA_BASE_DISTRO}-${KOLLA_INSTALL_TYPE}-swift-base:${KOLLA_VERSION} swift-ring-builder \
        /etc/kolla/config/swift/container.builder add r1z1-${SWIFT_STORAGE_ADDRESS}:16002/d${i} 1;
done

for ring in object account container; do
    docker run \
        -v /etc/kolla/config/swift/:/etc/kolla/config/swift/ \
        registry.local:5000/${KOLLA_DOCKER_NAMESPACE}/${KOLLA_BASE_DISTRO}-${KOLLA_INSTALL_TYPE}-swift-base:${KOLLA_VERSION} swift-ring-builder \
        /etc/kolla/config/swift/${ring}.builder rebalance;
done

