# InsightSemantic All-in-One Runtime
# Canonical image name: InsightSemantic:<version>
# Build context MUST be the staged directory produced by scripts/stage-release.sh
# Target: Ubuntu 22.04 (jammy) + ROS 2 Humble, linux/amd64

ARG RELEASE_VERSION=1.0.0
FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ARG RELEASE_VERSION=1.0.0
ARG ROS_DISTRO=humble

ENV RELEASE_VERSION=${RELEASE_VERSION} \
    ROS_DISTRO=${ROS_DISTRO} \
    ROS_DOMAIN_ID=0 \
    FASTDDS_BUILTIN_TRANSPORTS=UDPv4 \
    MUJOCO_GL=egl \
    PLUGIN_MUJOCO_GUI_MODE=off \
    PLUGIN_MUJOCO_HOME=/opt/plugin-mujoco \
    RELEASE_HOME=/opt/InsightOS \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    TZ=Asia/Shanghai

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl gnupg2 lsb-release locales tzdata \
    tini supervisor nginx redis-server \
    mysql-server mysql-client \
    python3 python3-pip python3-venv python3-tk \
    procps iproute2 netcat-openbsd wget \
    libegl1 libgl1 libgl1-mesa-dri libglew2.2 libglfw3 \
    libglib2.0-0 libosmesa6 libsm6 \
    libx11-6 libxcursor1 libxext6 libxi6 libxinerama1 \
    libxkbcommon0 libxkbcommon-x11-0 libxrandr2 libxrender1 \
    x11-utils xauth \
    python3-opengl \
    && locale-gen en_US en_US.UTF-8 \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo Asia/Shanghai > /etc/timezone \
    && rm -rf /var/lib/apt/lists/*

# ROS 2 Humble
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
      -o /usr/share/keyrings/ros-archive-keyring.gpg \
 && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu jammy main" \
      > /etc/apt/sources.list.d/ros2.list \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
      ros-${ROS_DISTRO}-ros-base \
      ros-${ROS_DISTRO}-rosbridge-suite \
      ros-${ROS_DISTRO}-rclpy \
      ros-${ROS_DISTRO}-sensor-msgs \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/InsightOS

# Install MuJoCo deb content without running systemd postinst hooks.
# dpkg -i in a container often leaves the package half-configured (rc).
COPY mujoco/plugin-mujoco.deb /tmp/plugin-mujoco.deb
RUN apt-get update \
 && apt-get install -y --no-install-recommends binutils \
 && dpkg-deb -x /tmp/plugin-mujoco.deb / \
 && dpkg-deb -e /tmp/plugin-mujoco.deb /tmp/plugin-mujoco-control \
 && mkdir -p /var/lib/dpkg/info \
 && rm -f /tmp/plugin-mujoco.deb \
 && test -x /opt/plugin-mujoco/plugin-mujoco \
 && test -x /opt/plugin-mujoco/start.sh \
 && rm -f /etc/systemd/system/plugin-mujoco.service \
        /etc/systemd/system/plugin-mujoco-bootstrap.service \
 && apt-get install -y --no-install-recommends python3-opengl \
 && rm -rf /opt/plugin-mujoco/_internal/OpenGL \
 && cp -a /usr/lib/python3/dist-packages/OpenGL /opt/plugin-mujoco/_internal/OpenGL \
 && rm -rf /var/lib/apt/lists/*

# Web viewer + release MuJoCo config
COPY mujoco/web-viewer/dist/ /opt/plugin-mujoco/web-viewer/dist/
COPY configs/comm_config.yaml /opt/plugin-mujoco/config/comm_config.yaml

# Application binaries and configs
COPY bin/ /opt/InsightOS/bin/
COPY configs/ /opt/InsightOS/configs/
COPY web/ /opt/InsightOS/web/
COPY services/ /opt/InsightOS/services/
COPY seed/ /opt/InsightOS/seed/
COPY templates/ /opt/InsightOS/templates/
COPY runtime/ /opt/InsightOS/runtime/
COPY nginx/ /opt/InsightOS/nginx/
COPY meta/ /opt/InsightOS/meta/

# Ability frameworks (binaries + compiled skill_library + packages)
COPY ability/ /opt/ability/

# semantic-map 已改为 /opt/InsightOS/bin/semantic-map 二进制启动，无需再 pip 装 FastAPI。
# Ability: CPU venv (torch CPU wheels + ultralytics for YOLO/semnav; no CUDA).
# skill_library shipped as .so under /opt/ability/v{1,2}.
RUN chmod +x /opt/InsightOS/bin/* /opt/InsightOS/runtime/*.sh \
    /opt/ability/v1/skill_ability/framework/AbilityFramework \
    /opt/ability/v2/skill_ability/framework/AbilityFramework \
 && mkdir -p /opt/ability/bin /opt/ability/venv \
 && python3 -m venv /opt/ability/venv \
 && /opt/ability/venv/bin/pip install --no-cache-dir -U pip setuptools wheel \
 && /opt/ability/venv/bin/pip install --no-cache-dir \
      --index-url https://download.pytorch.org/whl/cpu \
      torch torchvision \
 && /opt/ability/venv/bin/pip install --no-cache-dir \
      -i https://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com \
      -r /opt/ability/requirements-cpu.txt \
 && /opt/ability/venv/bin/pip install --no-cache-dir /opt/ability/wheels/ability_py-*.whl \
 && if [[ -f /opt/ability/wheels/ability_tool ]]; then cp -a /opt/ability/wheels/ability_tool /opt/ability/bin/ && chmod +x /opt/ability/bin/ability_tool; fi \
 && mkdir -p \
      /opt/InsightOS/data/semantic \
      /opt/InsightOS/data/studio/workspace \
      /opt/InsightOS/data/studio/logs \
      /opt/InsightOS/data/semantic-map \
      /opt/plugin-mujoco/output \
      /opt/plugin-mujoco/logs \
      /opt/plugin-mujoco/runtime \
      /opt/sim_asset/mujoco \
      /run/mysqld \
      /var/log/supervisor \
      /var/log/nginx \
 && chown -R mysql:mysql /var/lib/mysql /run/mysqld \
 && rm -f /etc/nginx/sites-enabled/default \
 && ln -sf /opt/InsightOS/nginx/default.conf /etc/nginx/conf.d/default.conf \
 && ln -sf /opt/InsightOS/configs/supervisord.conf /etc/supervisor/supervisord.conf

ENV PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/ability/venv/bin" \
    VIRTUAL_ENV=/opt/ability/venv

# rosbridge/ros2cli must use system Python (not ability venv) for tornado/netifaces.
RUN apt-get update \
 && apt-get install -y --no-install-recommends python3-tornado python3-netifaces \
 && rm -rf /var/lib/apt/lists/*

VOLUME ["/opt/InsightOS/data/semantic", "/opt/InsightOS/data/studio/workspace", "/opt/InsightOS/data/studio/logs", "/var/lib/mysql", "/var/lib/redis", "/opt/plugin-mujoco/output", "/opt/plugin-mujoco/logs", "/opt/sim_asset/mujoco", "/opt/InsightOS/data/semantic-map"]

# Host network: ports are documented, not published by Docker
# 80 nginx | 38080/8081 semantic | 38083/38084 map | 18080 studio
# 8000/8001+ mujoco | 9091 rosbridge | 9100/9101 pilot1 | 9200/9201 pilot2
# 48080/48081 ability | 3306 mysql | 6379 redis

HEALTHCHECK --interval=20s --timeout=10s --retries=12 --start-period=90s \
  CMD /opt/InsightOS/runtime/doctor.sh healthcheck

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/opt/InsightOS/runtime/entrypoint.sh"]
