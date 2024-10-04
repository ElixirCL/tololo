-- SQL dump generated using DBML (dbml.dbdiagram.io)
-- Database: PostgreSQL
-- Generated at: 2024-10-03T21:18:36.571Z

CREATE TABLE "roles" (
  "id" text PRIMARY KEY,
  "name" text NOT NULL,
  "inserted_at" timestamp NOT NULL DEFAULT (now()),
  "updated_at" timestamp NOT NULL DEFAULT (now())
);

CREATE TABLE "permissions" (
  "id" text PRIMARY KEY,
  "name" text NOT NULL,
  "inserted_at" timestamp NOT NULL DEFAULT (now()),
  "updated_at" timestamp NOT NULL DEFAULT (now())
);

CREATE TABLE "role_permissions" (
  "id" text PRIMARY KEY,
  "role_id" text NOT NULL,
  "permission_id" text NOT NULL
);

CREATE TABLE "users" (
  "id" text PRIMARY KEY,
  "name" text NOT NULL,
  "password" text,
  "contact_id" text,
  "last_login_at" timestamp NOT NULL DEFAULT (now()),
  "inserted_at" timestamp NOT NULL DEFAULT (now()),
  "updated_at" timestamp NOT NULL DEFAULT (now())
);

CREATE TABLE "users_roles" (
  "id" text PRIMARY KEY,
  "user_id" text NOT NULL,
  "role_id" text NOT NULL
);

CREATE TABLE "customers" (
  "id" text PRIMARY KEY,
  "user_id" text,
  "inserted_at" timestamp NOT NULL DEFAULT (now()),
  "updated_at" timestamp NOT NULL DEFAULT (now())
);

CREATE TABLE "contacts" (
  "id" text PRIMARY KEY,
  "type_id" text NOT NULL,
  "inserted_at" timestamp NOT NULL DEFAULT (now()),
  "updated_at" timestamp NOT NULL DEFAULT (now())
);

CREATE TABLE "contacts_types" (
  "id" text PRIMARY KEY,
  "value" text,
  "inserted_at" timestamp NOT NULL DEFAULT (now()),
  "updated_at" timestamp NOT NULL DEFAULT (now())
);

CREATE TABLE "activity_logs" (
  "id" text PRIMARY KEY,
  "origin" text NOT NULL,
  "action" text NOT NULL,
  "content" json NOT NULL,
  "inserted_at" timestamp NOT NULL DEFAULT (now())
);

COMMENT ON COLUMN "roles"."id" IS 'uuidv7';

COMMENT ON COLUMN "permissions"."id" IS 'uuidv7';

COMMENT ON COLUMN "role_permissions"."id" IS 'uuidv7';

COMMENT ON COLUMN "users"."id" IS 'uuidv7';

COMMENT ON COLUMN "users"."password" IS 'bcrypt';

COMMENT ON COLUMN "users_roles"."id" IS 'uuidv7';

COMMENT ON COLUMN "customers"."id" IS 'uuidv7';

COMMENT ON COLUMN "contacts"."id" IS 'uuidv7';

COMMENT ON COLUMN "contacts_types"."id" IS 'uuidv7';

COMMENT ON COLUMN "contacts_types"."value" IS 'person or organization';

COMMENT ON COLUMN "activity_logs"."id" IS 'uuidv7';

COMMENT ON COLUMN "activity_logs"."origin" IS 'where the event was generated';

COMMENT ON COLUMN "activity_logs"."action" IS 'an identifier of the action or general context';

COMMENT ON COLUMN "activity_logs"."content" IS 'json string with relevant data of the event';

ALTER TABLE "role_permissions" ADD FOREIGN KEY ("role_id") REFERENCES "roles" ("id");

ALTER TABLE "role_permissions" ADD FOREIGN KEY ("permission_id") REFERENCES "permissions" ("id");

ALTER TABLE "users_roles" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");

ALTER TABLE "users_roles" ADD FOREIGN KEY ("role_id") REFERENCES "roles" ("id");

ALTER TABLE "customers" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");

ALTER TABLE "contacts" ADD FOREIGN KEY ("id") REFERENCES "users" ("contact_id");

ALTER TABLE "contacts" ADD FOREIGN KEY ("type_id") REFERENCES "contacts_types" ("id");
