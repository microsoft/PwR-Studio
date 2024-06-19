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
    is_pbyc_viewable boolean,
    is_user_viewable boolean,
    created_at timestamp without time zone
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
-- Data for Name: analytics_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--




--
-- Name: analytics_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.analytics_logs_id_seq', 1, true);


--
-- Name: dev_chat_messages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dev_chat_messages_id_seq', 1, true);


--
-- Name: exports_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.exports_id_seq', 1, false);


--
-- Name: output_chat_messages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.output_chat_messages_id_seq', 1, false);


--
-- Name: plugins_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.plugins_id_seq', 1, false);


--
-- Name: project_has_credentials_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.project_has_credentials_id_seq', 1, false);


--
-- Name: projects_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.projects_id_seq', 1, true);


--
-- Name: representation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.representation_id_seq', 1, true);


--
-- Name: tags_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tags_id_seq', 1, false);


--
-- Name: template_has_credentials_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.template_has_credentials_id_seq', 1, false);


--
-- Name: template_has_plugins_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.template_has_plugins_id_seq', 1, false);


--
-- Name: template_has_tags_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.template_has_tags_id_seq', 1, false);


--
-- Name: templates_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.templates_id_seq', 1, false);


--
-- Name: users_has_projects_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_has_projects_id_seq', 1, true);


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

--
-- PostgreSQL database dump
--

--
-- Data for Name: templates; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.templates (id, name, description, project_class, created_at, updated_at, engine_url, file_upload, audio_upload, has_credentials, verified, sort) FROM stdin;
1	JB App	Use this to create apps using JugalBandi	jb_app	2023-05-10 07:32:03.987439	2023-05-04 13:47:56.492011	f	f	f	f	t	0
\.


--
-- Data for Name: plugins; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.plugins (id, name, description, pypi_url, dsl, doc, icon, created_at, updated_at) FROM stdin;
1	Knowledge Base	Fetch data from a trusted or validated knowledgebase	https://raw.githubusercontent.com/OpenNyAI/Jugalbandi-Studio-Engine/main/plugins/knowledge_plugin.yaml			data:image/png;base64,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	2023-11-24 09:05:53.86371	2023-11-24 09:05:53.86371
2	Reasoning Engine	Using advanced capabilities of AI models  (LLMs) to reason over knowledge based on a task	https://raw.githubusercontent.com/OpenNyAI/Jugalbandi-Studio-Engine/main/plugins/reasoning_plugin.yaml			data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAgAAAAIACAYAAAD0eNT6AAAAAXNSR0IArs4c6QAAIABJREFUeF7t3QmYJVV5//H3rdvTzAz8ZVNHoZlbVd2KGY0b/yguRCSuQcCVqIlGTVQif+OumGAWzYZGY9zilkhEg0LEBdS4ggsKKlGJ6WSgu6ruMIygDELEGabpW+dP6RCGEWZO9T33Vp06334en+R55tR7zvm8h57fdNetUuELAQQQQAABBIIT0OB2zIYRQAABBBBAQAgAHAIEEEAAAQQCFCAABNh0towAAggggAABgDOAAAIIIIBAgAIEgACbzpYRQAABBBAgAHAGEEAAAQQQCFCAABBg09kyAggggAACBADOAAIIIIAAAgEKEAACbDpbRgABBBBAgADAGUAAAQQQQCBAAQJAgE1nywgggAACCBAAOAMIIIAAAggEKEAACLDpbBkBBBBAAAECAGcAAQQQQACBAAUIAAE2nS0jgAACCCBAAOAMIIAAAgggEKAAASDAprNlBBBAAAEECACcAQQQQAABBAIUIAAE2HS2jAACCCCAAAGAM4AAAggggECAAgSAAJvOlhFAAAEEECAAcAYQQAABBBAIUIAAEGDT2TICCCCAAAIEAM4AAggggAACAQoQAAJsOltGAAEEEECAAMAZQAABBBBAIEABAkCATWfLCCCAAAIIEAA4AwgggAACCAQoQAAIsOlsGQEEEEAAAQIAZwABBBBAAIEABQgAATadLSOAAAIIIEAA4AwggAACCCAQoAABIMCms2UEEEAAAQQIAJwBBBBAAAEEAhQgAATYdLaMAAIIIIAAAYAzgAACCCCAQIACBIAAm86WEUAAAQQQIABwBhBAAAEEEAhQgAAQYNPZMgIIIIAAAgQAzgACCCCAAAIBChAAAmw6W0YAAQQQQIAAwBlAAAEEEEAgQAECQIBNZ8sIIIAAAggQADgDCCCAAAIIBChAAAiw6WwZAQQQQAABAgBnAAEEEEAAgQAFCAABNp0tI4AAAgggQADgDCCAAAIIIBCgAAEgwKazZQQQQAABBAgAnAEEEEAAAQQCFCAABNh0towAAggggAABgDOAAAIIIIBAgAIEgACbzpYRQAABBBAgAHAGEEAAAQQQCFCAABBg09kyAggggAACBADOAAIIIIAAAgEKEAACbDpbRgABBBBAgADAGUAAAQQQQCBA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	2023-11-24 09:05:53.86371	2023-11-24 09:05:53.86371
3	Payment	Using a payment gateway to collect money from user	https://raw.githubusercontent.com/OpenNyAI/Jugalbandi-Studio-Engine/main/plugins/payment.yaml			data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAgAAAAIACAYAAAD0eNT6AAAAAXNSR0IArs4c6QAAIABJREFUeF7t3QmYJVV5//H3rdvTzAz8ZVNHoZlbVd2KGY0b/yguRCSuQcCVqIlGTVQif+OumGAWzYZGY9zilkhEg0LEBdS4ggsKKlGJ6WSgu6ruMIygDELEGabpW+dP6RCGEWZO9T33Vp06334en+R55tR7zvm8h57fdNetUuELAQQQQAABBIIT0OB2zIYRQAABBBBAQAgAHAIEEEAAAQQCFCAABNh0towAAggggAABgDOAAAIIIIBAgAIEgACbzpYRQAABBBAgAHAGEEAAAQQQCFCAABBg09kyAggggAACBADOAAIIIIAAAgEKEAACbDpbRgABBBBAgADAGUAAAQQQQCBAAQJAgE1nywgggAACCBAAOAMIIIAAAggEKEAACLDpbBkBBBBAAAECAGcAAQQQQACBAAUIAAE2nS0jgAACCCBAAOAMIIAAAgggEKAAASDAprNlBBBAAAEECACcAQQQQAABBAIUIAAE2HS2jAACCCCAAAGAM4AAAggggECAAgSAAJvOlhFAAAEEECAAcAYQQAABBBAIUIAAEGDT2TICCCCAAAIEAM4AAggggAACAQoQAAJsOltGAAEEEECAAMAZQAABBBBAIEABAkCATWfLCCCAAAIIEAA4AwgggAACCAQoQAAIsOlsGQEEEEAAAQIAZwABBBBAAIEABQgAATadLSOAAAIIIEAA4AwggAACCCAQoAABIMCms2UEEEAAAQQIAJwBBBBAAAEEAhQgAATYdLaMAAIIIIAAAYAzgAACCCCAQIACBIAAm86WEUAAAQQQIABwBhBAAAEEEAhQgAAQYNPZMgIIIIAAAgQAzgACCCCAAAIBChAAAmw6W0YAAQQQQIAAwBlAAAEEEEAgQAECQIBNZ8sIIIAAAggQADgDCCCAAAIIBChAAAiw6WwZAQQQQAABAgBnAAEEEEAAgQAFCAABNp0tI4AAAgggQADgDCCAAAIIIBCgAAEgwKazZQQQQAABBAgAnAEEEEAAAQQCFCAABNh0towAAggggAABgDOAAAIIIIBAgAIEgACbzpYRQAABBBAgAHAGEEAAAQQQCFCAABBg09kyAggggAACBADOAAIIIIAAAgEKEAACbDpbRgABBBBAgADAGUAAAQQQQCBA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	2023-11-24 09:05:53.86371	2023-11-24 09:05:53.86371
\.


--
-- Data for Name: templates; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.templates (id, name, description, project_class, created_at, updated_at, engine_url, file_upload, audio_upload, has_credentials, verified, sort) VALUES (1, 'JB App', 'Use this to create apps using JugalBandi', 'jb_app', '2023-05-10 07:32:03.987439', '2023-05-04 13:47:56.492011', false, false, false, false, true, 0);


--
-- Data for Name: template_has_plugins; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.template_has_plugins (id, template_id, plugin_id) FROM stdin;
1	1	1
2	1	2
3	1	3
\.


--
-- Data for Name: template_has_tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.template_has_tags (id, template_id, tag_id) FROM stdin;
\.

--
-- PostgreSQL database dump complete
--

