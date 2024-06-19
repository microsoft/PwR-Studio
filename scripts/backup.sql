--
-- PostgreSQL database dump
--

-- Dumped from database version 16.1 (Debian 16.1-1.pgdg120+1)
-- Dumped by pg_dump version 16.1 (Debian 16.1-1.pgdg120+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: chat_message_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.chat_message_type AS ENUM (
    'instruction',
    'feedback',
    'thought',
    'output',
    'start',
    'dsl_state',
    'end',
    'error',
    'representation_edit',
    'files'
);


ALTER TYPE public.chat_message_type OWNER TO postgres;

--
-- Name: chat_user_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.chat_user_type AS ENUM (
    'user',
    'bot'
);


ALTER TYPE public.chat_user_type OWNER TO postgres;

--
-- Name: output_message_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.output_message_type AS ENUM (
    'instruction',
    'feedback',
    'thought',
    'output',
    'callback',
    'debug',
    'start',
    'end',
    'error'
);


ALTER TYPE public.output_message_type OWNER TO postgres;

--
-- Name: output_user_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.output_user_type AS ENUM (
    'user',
    'bot'
);


ALTER TYPE public.output_user_type OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


ALTER TABLE public.alembic_version OWNER TO postgres;

--
-- Name: analytics_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.analytics_logs (
    id integer NOT NULL,
    name character varying,
    project_id integer,
    user_id character varying,
    representation_name character varying,
    data json,
    "timestamp" timestamp without time zone
);


ALTER TABLE public.analytics_logs OWNER TO postgres;

--
-- Name: analytics_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.analytics_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.analytics_logs_id_seq OWNER TO postgres;

--
-- Name: analytics_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.analytics_logs_id_seq OWNED BY public.analytics_logs.id;


--
-- Name: dev_chat_messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dev_chat_messages (
    id integer NOT NULL,
    session_id character varying,
    project_id integer,
    sender_id character varying,
    sender public.chat_user_type,
    type public.chat_message_type,
    message character varying,
    created_at timestamp without time zone,
    special_link character varying,
    pbyc_comments character varying
);


ALTER TABLE public.dev_chat_messages OWNER TO postgres;

--
-- Name: dev_chat_messages_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.dev_chat_messages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.dev_chat_messages_id_seq OWNER TO postgres;

--
-- Name: dev_chat_messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.dev_chat_messages_id_seq OWNED BY public.dev_chat_messages.id;


--
-- Name: exports; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.exports (
    id integer NOT NULL,
    project_id integer,
    sandbox_responsecode integer,
    created_at timestamp without time zone
);


ALTER TABLE public.exports OWNER TO postgres;

--
-- Name: exports_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.exports_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.exports_id_seq OWNER TO postgres;

--
-- Name: exports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.exports_id_seq OWNED BY public.exports.id;


--
-- Name: output_chat_messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.output_chat_messages (
    id integer NOT NULL,
    session_id character varying,
    sender_id character varying,
    project_id integer,
    sender public.output_user_type,
    type public.output_message_type,
    message character varying,
    created_at timestamp without time zone,
    special_link character varying,
    pbyc_comments character varying
);


ALTER TABLE public.output_chat_messages OWNER TO postgres;

--
-- Name: output_chat_messages_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.output_chat_messages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.output_chat_messages_id_seq OWNER TO postgres;

--
-- Name: output_chat_messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.output_chat_messages_id_seq OWNED BY public.output_chat_messages.id;


--
-- Name: plugins; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.plugins (
    id integer NOT NULL,
    name character varying,
    description character varying,
    pypi_url character varying,
    dsl character varying,
    doc character varying,
    icon character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.plugins OWNER TO postgres;

--
-- Name: plugins_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.plugins_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.plugins_id_seq OWNER TO postgres;

--
-- Name: plugins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.plugins_id_seq OWNED BY public.plugins.id;


--
-- Name: project_has_credentials; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.project_has_credentials (
    id integer NOT NULL,
    project_id integer,
    name character varying,
    description character varying,
    mandatory boolean,
    created_at timestamp without time zone
);


ALTER TABLE public.project_has_credentials OWNER TO postgres;

--
-- Name: project_has_credentials_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.project_has_credentials_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.project_has_credentials_id_seq OWNER TO postgres;

--
-- Name: project_has_credentials_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.project_has_credentials_id_seq OWNED BY public.project_has_credentials.id;


--
-- Name: projects; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.projects (
    id integer NOT NULL,
    name character varying,
    description character varying,
    project_class character varying,
    parent_id integer,
    output_url character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    is_template boolean,
    is_deleted boolean,
    engine_url boolean,
    file_upload boolean,
    audio_upload boolean,
    has_credentials boolean
);


ALTER TABLE public.projects OWNER TO postgres;

--
-- Name: projects_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.projects_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.projects_id_seq OWNER TO postgres;

--
-- Name: projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.projects_id_seq OWNED BY public.projects.id;


--
-- Name: representation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.representation (
    id integer NOT NULL,
    name character varying,
    type character varying,
    text character varying,
    project_id integer,
    is_editable boolean,
    sort_order integer,
    is_user_viewable boolean,
    created_at timestamp without time zone,
    is_pwr_viewable boolean
);


ALTER TABLE public.representation OWNER TO postgres;

--
-- Name: representation_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.representation_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.representation_id_seq OWNER TO postgres;

--
-- Name: representation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.representation_id_seq OWNED BY public.representation.id;


--
-- Name: tags; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tags (
    id integer NOT NULL,
    name character varying
);


ALTER TABLE public.tags OWNER TO postgres;

--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tags_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tags_id_seq OWNER TO postgres;

--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tags_id_seq OWNED BY public.tags.id;


--
-- Name: template_has_credentials; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.template_has_credentials (
    id integer NOT NULL,
    template_id integer,
    name character varying,
    description character varying,
    mandatory boolean,
    created_at timestamp without time zone
);


ALTER TABLE public.template_has_credentials OWNER TO postgres;

--
-- Name: template_has_credentials_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.template_has_credentials_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.template_has_credentials_id_seq OWNER TO postgres;

--
-- Name: template_has_credentials_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.template_has_credentials_id_seq OWNED BY public.template_has_credentials.id;


--
-- Name: template_has_plugins; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.template_has_plugins (
    id integer NOT NULL,
    template_id integer,
    plugin_id integer
);


ALTER TABLE public.template_has_plugins OWNER TO postgres;

--
-- Name: template_has_plugins_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.template_has_plugins_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.template_has_plugins_id_seq OWNER TO postgres;

--
-- Name: template_has_plugins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.template_has_plugins_id_seq OWNED BY public.template_has_plugins.id;


--
-- Name: template_has_tags; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.template_has_tags (
    id integer NOT NULL,
    template_id integer,
    tag_id integer
);


ALTER TABLE public.template_has_tags OWNER TO postgres;

--
-- Name: template_has_tags_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.template_has_tags_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.template_has_tags_id_seq OWNER TO postgres;

--
-- Name: template_has_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.template_has_tags_id_seq OWNED BY public.template_has_tags.id;


--
-- Name: templates; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.templates (
    id integer NOT NULL,
    name character varying,
    description character varying,
    project_class character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    engine_url boolean,
    file_upload boolean,
    audio_upload boolean,
    has_credentials boolean,
    verified boolean,
    sort integer
);


ALTER TABLE public.templates OWNER TO postgres;

--
-- Name: templates_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.templates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.templates_id_seq OWNER TO postgres;

--
-- Name: templates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.templates_id_seq OWNED BY public.templates.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    oid character varying NOT NULL,
    name character varying,
    email character varying,
    created_at timestamp without time zone
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_has_projects; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users_has_projects (
    id integer NOT NULL,
    oid character varying,
    project_id integer,
    created_at timestamp without time zone
);


ALTER TABLE public.users_has_projects OWNER TO postgres;

--
-- Name: users_has_projects_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_has_projects_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_has_projects_id_seq OWNER TO postgres;

--
-- Name: users_has_projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_has_projects_id_seq OWNED BY public.users_has_projects.id;


--
-- Name: analytics_logs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.analytics_logs ALTER COLUMN id SET DEFAULT nextval('public.analytics_logs_id_seq'::regclass);


--
-- Name: dev_chat_messages id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dev_chat_messages ALTER COLUMN id SET DEFAULT nextval('public.dev_chat_messages_id_seq'::regclass);


--
-- Name: exports id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.exports ALTER COLUMN id SET DEFAULT nextval('public.exports_id_seq'::regclass);


--
-- Name: output_chat_messages id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.output_chat_messages ALTER COLUMN id SET DEFAULT nextval('public.output_chat_messages_id_seq'::regclass);


--
-- Name: plugins id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plugins ALTER COLUMN id SET DEFAULT nextval('public.plugins_id_seq'::regclass);


--
-- Name: project_has_credentials id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_has_credentials ALTER COLUMN id SET DEFAULT nextval('public.project_has_credentials_id_seq'::regclass);


--
-- Name: projects id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.projects ALTER COLUMN id SET DEFAULT nextval('public.projects_id_seq'::regclass);


--
-- Name: representation id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.representation ALTER COLUMN id SET DEFAULT nextval('public.representation_id_seq'::regclass);


--
-- Name: tags id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tags ALTER COLUMN id SET DEFAULT nextval('public.tags_id_seq'::regclass);


--
-- Name: template_has_credentials id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.template_has_credentials ALTER COLUMN id SET DEFAULT nextval('public.template_has_credentials_id_seq'::regclass);


--
-- Name: template_has_plugins id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.template_has_plugins ALTER COLUMN id SET DEFAULT nextval('public.template_has_plugins_id_seq'::regclass);


--
-- Name: template_has_tags id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.template_has_tags ALTER COLUMN id SET DEFAULT nextval('public.template_has_tags_id_seq'::regclass);


--
-- Name: templates id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.templates ALTER COLUMN id SET DEFAULT nextval('public.templates_id_seq'::regclass);


--
-- Name: users_has_projects id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_has_projects ALTER COLUMN id SET DEFAULT nextval('public.users_has_projects_id_seq'::regclass);


--
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- Name: analytics_logs analytics_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.analytics_logs
    ADD CONSTRAINT analytics_logs_pkey PRIMARY KEY (id);


--
-- Name: dev_chat_messages dev_chat_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dev_chat_messages
    ADD CONSTRAINT dev_chat_messages_pkey PRIMARY KEY (id);


--
-- Name: exports exports_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.exports
    ADD CONSTRAINT exports_pkey PRIMARY KEY (id);


--
-- Name: output_chat_messages output_chat_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.output_chat_messages
    ADD CONSTRAINT output_chat_messages_pkey PRIMARY KEY (id);


--
-- Name: plugins plugins_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plugins
    ADD CONSTRAINT plugins_pkey PRIMARY KEY (id);


--
-- Name: project_has_credentials project_has_credentials_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_has_credentials
    ADD CONSTRAINT project_has_credentials_pkey PRIMARY KEY (id);


--
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: representation representation_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.representation
    ADD CONSTRAINT representation_pkey PRIMARY KEY (id);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: template_has_credentials template_has_credentials_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.template_has_credentials
    ADD CONSTRAINT template_has_credentials_pkey PRIMARY KEY (id);


--
-- Name: template_has_plugins template_has_plugins_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.template_has_plugins
    ADD CONSTRAINT template_has_plugins_pkey PRIMARY KEY (id);


--
-- Name: template_has_tags template_has_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.template_has_tags
    ADD CONSTRAINT template_has_tags_pkey PRIMARY KEY (id);


--
-- Name: templates templates_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.templates
    ADD CONSTRAINT templates_pkey PRIMARY KEY (id);


--
-- Name: users_has_projects users_has_projects_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_has_projects
    ADD CONSTRAINT users_has_projects_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (oid);


--
-- Name: ix_analytics_logs_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_analytics_logs_id ON public.analytics_logs USING btree (id);


--
-- Name: ix_analytics_logs_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_analytics_logs_name ON public.analytics_logs USING btree (name);


--
-- Name: ix_analytics_logs_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_analytics_logs_project_id ON public.analytics_logs USING btree (project_id);


--
-- Name: ix_analytics_logs_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_analytics_logs_user_id ON public.analytics_logs USING btree (user_id);


--
-- Name: ix_dev_chat_messages_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_dev_chat_messages_id ON public.dev_chat_messages USING btree (id);


--
-- Name: ix_dev_chat_messages_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_dev_chat_messages_project_id ON public.dev_chat_messages USING btree (project_id);


--
-- Name: ix_exports_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_exports_id ON public.exports USING btree (id);


--
-- Name: ix_exports_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_exports_project_id ON public.exports USING btree (project_id);


--
-- Name: ix_output_chat_messages_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_output_chat_messages_id ON public.output_chat_messages USING btree (id);


--
-- Name: ix_output_chat_messages_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_output_chat_messages_project_id ON public.output_chat_messages USING btree (project_id);


--
-- Name: ix_plugins_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_plugins_id ON public.plugins USING btree (id);


--
-- Name: ix_plugins_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_plugins_name ON public.plugins USING btree (name);


--
-- Name: ix_project_has_credentials_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_project_has_credentials_id ON public.project_has_credentials USING btree (id);


--
-- Name: ix_project_has_credentials_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_project_has_credentials_project_id ON public.project_has_credentials USING btree (project_id);


--
-- Name: ix_projects_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_projects_id ON public.projects USING btree (id);


--
-- Name: ix_projects_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_projects_name ON public.projects USING btree (name);


--
-- Name: ix_representation_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_representation_id ON public.representation USING btree (id);


--
-- Name: ix_representation_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_representation_name ON public.representation USING btree (name);


--
-- Name: ix_representation_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_representation_project_id ON public.representation USING btree (project_id);


--
-- Name: ix_tags_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tags_id ON public.tags USING btree (id);


--
-- Name: ix_tags_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tags_name ON public.tags USING btree (name);


--
-- Name: ix_template_has_credentials_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_template_has_credentials_id ON public.template_has_credentials USING btree (id);


--
-- Name: ix_template_has_credentials_template_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_template_has_credentials_template_id ON public.template_has_credentials USING btree (template_id);


--
-- Name: ix_template_has_plugins_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_template_has_plugins_id ON public.template_has_plugins USING btree (id);


--
-- Name: ix_template_has_plugins_plugin_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_template_has_plugins_plugin_id ON public.template_has_plugins USING btree (plugin_id);


--
-- Name: ix_template_has_plugins_template_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_template_has_plugins_template_id ON public.template_has_plugins USING btree (template_id);


--
-- Name: ix_template_has_tags_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_template_has_tags_id ON public.template_has_tags USING btree (id);


--
-- Name: ix_template_has_tags_tag_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_template_has_tags_tag_id ON public.template_has_tags USING btree (tag_id);


--
-- Name: ix_template_has_tags_template_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_template_has_tags_template_id ON public.template_has_tags USING btree (template_id);


--
-- Name: ix_templates_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_templates_id ON public.templates USING btree (id);


--
-- Name: ix_templates_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_templates_name ON public.templates USING btree (name);


--
-- Name: ix_users_has_projects_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_users_has_projects_id ON public.users_has_projects USING btree (id);


--
-- Name: ix_users_has_projects_oid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_users_has_projects_oid ON public.users_has_projects USING btree (oid);


--
-- Name: ix_users_has_projects_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_users_has_projects_project_id ON public.users_has_projects USING btree (project_id);


--
-- Name: ix_users_oid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_users_oid ON public.users USING btree (oid);


--
-- Name: analytics_logs analytics_logs_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.analytics_logs
    ADD CONSTRAINT analytics_logs_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: analytics_logs analytics_logs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.analytics_logs
    ADD CONSTRAINT analytics_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(oid);


--
-- Name: dev_chat_messages dev_chat_messages_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dev_chat_messages
    ADD CONSTRAINT dev_chat_messages_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: exports exports_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.exports
    ADD CONSTRAINT exports_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: output_chat_messages output_chat_messages_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.output_chat_messages
    ADD CONSTRAINT output_chat_messages_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: project_has_credentials project_has_credentials_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_has_credentials
    ADD CONSTRAINT project_has_credentials_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: representation representation_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.representation
    ADD CONSTRAINT representation_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: template_has_credentials template_has_credentials_template_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.template_has_credentials
    ADD CONSTRAINT template_has_credentials_template_id_fkey FOREIGN KEY (template_id) REFERENCES public.templates(id);


--
-- Name: template_has_plugins template_has_plugins_plugin_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.template_has_plugins
    ADD CONSTRAINT template_has_plugins_plugin_id_fkey FOREIGN KEY (plugin_id) REFERENCES public.plugins(id);


--
-- Name: template_has_plugins template_has_plugins_template_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.template_has_plugins
    ADD CONSTRAINT template_has_plugins_template_id_fkey FOREIGN KEY (template_id) REFERENCES public.templates(id);


--
-- Name: template_has_tags template_has_tags_tag_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.template_has_tags
    ADD CONSTRAINT template_has_tags_tag_id_fkey FOREIGN KEY (tag_id) REFERENCES public.tags(id);


--
-- Name: template_has_tags template_has_tags_template_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.template_has_tags
    ADD CONSTRAINT template_has_tags_template_id_fkey FOREIGN KEY (template_id) REFERENCES public.templates(id);


--
-- Name: users_has_projects users_has_projects_oid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_has_projects
    ADD CONSTRAINT users_has_projects_oid_fkey FOREIGN KEY (oid) REFERENCES public.users(oid);


--
-- Name: users_has_projects users_has_projects_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_has_projects
    ADD CONSTRAINT users_has_projects_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- PostgreSQL database dump complete
--

