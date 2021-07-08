FROM node:12.22.1-buster-slim AS installer
RUN buildDependencies="ca-certificates make build-essential python3 libpq-dev postgresql-client" \
  && apt-get update && apt-get install -y --no-install-recommends ${buildDependencies}
WORKDIR /usr/deploy/
COPY . .
RUN cd Plv8 \
 && npm install

CMD cd Plv8 \
  && PGPASSWORD=${ADMIN_PASSWORD} psql -h ${PLV8_POSTGRES_HOST} -p ${PLV8_POSTGRES_PORT} -U ${ADMIN_USER} -a -c "CREATE USER ${PLV8_POSTGRES_USER} WITH PASSWORD '${PLV8_POSTGRES_PASSWORD}';" \
  && PGPASSWORD=${ADMIN_PASSWORD} psql -h ${PLV8_POSTGRES_HOST} -p ${PLV8_POSTGRES_PORT} -U ${ADMIN_USER} -a -c "CREATE DATABASE ${PLV8_DB_NAME}" \
  && PGPASSWORD=${ADMIN_PASSWORD} psql -h ${PLV8_POSTGRES_HOST} -p ${PLV8_POSTGRES_PORT} -U ${ADMIN_USER} -a -c "GRANT ALL PRIVILEGES ON DATABASE ${PLV8_DB_NAME} TO ${PLV8_POSTGRES_USER};" \
  && PGPASSWORD=${ADMIN_PASSWORD} psql -h ${PLV8_POSTGRES_HOST} -p ${PLV8_POSTGRES_PORT} -U ${ADMIN_USER} -d ${PLV8_DB_NAME} -a -c "ALTER SCHEMA public OWNER TO ${PLV8_POSTGRES_USER}" \
  && PGPASSWORD=${ADMIN_PASSWORD} psql -h ${PLV8_POSTGRES_HOST} -p ${PLV8_POSTGRES_PORT} -U ${ADMIN_USER} -d ${PLV8_DB_NAME} -a -c "CREATE EXTENSION plv8;" \
  && PGPASSWORD=${PLV8_POSTGRES_PASSWORD} psql -h ${PLV8_POSTGRES_HOST} -p ${PLV8_POSTGRES_PORT} -U ${PLV8_POSTGRES_USER} -d ${PLV8_DB_NAME} -a -f ./Sql/SchemaSetup.sql \
  && PGPASSWORD=${PLV8_POSTGRES_PASSWORD} psql -h ${PLV8_POSTGRES_HOST} -p ${PLV8_POSTGRES_PORT} -U ${PLV8_POSTGRES_USER} -d ${PLV8_DB_NAME} -a -f ./Sql/GrapqQlCreate.sql \
  && npm run deploy
