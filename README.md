# Docker Image to Restore Postgres databases
This image is based on a standard postgres image and supports restoring from dumps in s3 compatible storage using the aws cli.
The aws cli will be automatically installed when the env vars `AWS_S3_BUCKET` and `AWS_S3_PATH` are set.

[Dockerfile](https://github.com/baunach-it/postgres-restore/blob/main/Dockerfile)

## Usage
Create a .env file in the desired location
```bash
POSTGRES_RESTORE_TARGET_DB_HOST=localhost
POSTGRES_RESTORE_TARGET_DB_PORT=5432
POSTGRES_RESTORE_TARGET_USER=postgres
POSTGRES_RESTORE_TARGET_PASSWORD=mypassword
POSTGRES_RESTORE_TARGET_DB_NAME=target_db

//if s3 should be used, add these vars:
POSTGRES_RESTORE_AWS_ACCESS_KEY_ID=
POSTGRES_RESTORE_AWS_SECRET_ACCESS_KEY=
POSTGRES_RESTORE_AWS_DEFAULT_REGION=
POSTGRES_RESTORE_AWS_S3_BUCKET=
POSTGRES_RESTORE_AWS_S3_PATH=

// if custom cli version needed, set:
POSTGRES_RESTORE_AWS_CLI_VERSION=

// if custom s3 endpoint needed, set:
POSTGRES_RESTORE_S3_ENDPOINT=

POSTGRES_RESTORE_DUMPFILE=
```
then reference the .env file when running the container and use the `latest` postgres version or use a specific one like `18.0`
```bash
docker run --rm --env-file .env -e POSTGRES_RESTORE_DUMPFILE=dump.sql.gz -v /desired/backup/path:/restore --network desired-network baunach/postgres-restore:latest
```

## License
The Dockerfile and scripts in this repository are licensed under [MIT-0](LICENSE).

The image contains third-party software that is subject to its own licenses, including:
- PostgreSQL from the official `postgres` base image: PostgreSQL License
- Debian packages of the base image and those installed by the Dockerfile (`ca-certificates`, `dos2unix`, `gzip`, `curl`, `unzip`): their respective licenses
- AWS CLI v2, downloaded and installed by `entrypoint.sh` at container start when S3 is used: Apache-2.0
