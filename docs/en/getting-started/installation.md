# InsightSemantic Installation and Startup Guide

[简体中文](../../zh-CN/getting-started/installation.md)

**Prerequisites:** Docker (with Docker Compose) must be installed on the target machine. Installation and startup only require the `run-insightsemantic.sh` script.

## Standard Installation Flow

**Core principle:** After the environment is ready, you only need to run the `run-insightsemantic.sh` script. Image login, pulling, configuration generation, and service startup are all handled automatically by the script.

| Prepare environment | Place the script | Run the script | Access the service |
| --- | --- | --- | --- |
| Docker + Compose | Run directory | The only startup action | Verify in a browser |

**The only command you run:** Depending on whether you are already logged in to Harbor, whether the image needs to be pulled, or whether a Key is configured, just add the corresponding arguments to `run-insightsemantic.sh`; no manual Docker commands are needed.

## 1. Prepare the Run Directory

Copy `scripts/run-insightsemantic.sh` to an empty directory prepared for running the container. The examples below use `~/insightsemantic`:

```bash
mkdir -p ~/insightsemantic
cd ~/insightsemantic
chmod +x run-insightsemantic.sh
```

## 2. Pull the Image from Harbor and Start

On first run, log in with your Harbor account and pull the image. Replace the example username and password with your real credentials.

```bash
./run-insightsemantic.sh --user <HarborUsername> --password "<HarborPassword>"
```

The script automatically does the following:

- Generates `.env` and `docker-compose.yaml` in the current directory.
- Logs in to `git.insightos.cn:11016`.
- Pulls `git.insightos.cn:11016/framework/insightsemantic:1.0.0`.
- Tags the image locally as `insightsemantic:1.0.0`.
- Starts the InsightSemantic service.

> Configuration templates are available in the repository at [docker/docker-compose.yaml](../../../docker/docker-compose.yaml) and [docker/.env.example](../../../docker/.env.example). After generation, you can adjust the configuration manually by referring to these templates.

> If you are already logged in to Harbor, you can use the following command. Use `--pull` only when the `insightsemantic:1.0.0` image does not exist locally; there is no need to pull when the same image is already present.

```bash
./run-insightsemantic.sh --skip-login --pull
```

## 3. Configure the LLM Key (Optional)

Edit the `.env` file in the current directory and fill in at least one model Key. [docker/.env.example](../../../docker/.env.example) provides a full template of the variables. For example:

```bash
DEEPSEEK_API_KEY=<YourKey>
```

After configuring, run:

```bash
./run-insightsemantic.sh --skip-login
```

> Configuration location: the script syncs the `.env` file from the current directory to `/opt/jushi/.env` inside the container.

## 4. Open the Service and Run a Health Check

After the service starts, visit the following addresses in your browser:

- **Web:** http://127.0.0.1/
- **Community:** http://127.0.0.1/community
- **Health check:** http://127.0.0.1/healthz

## 5. Stop the Service

To stop the running service, run the following in the run directory:

```bash
./run-insightsemantic.sh --down
```
