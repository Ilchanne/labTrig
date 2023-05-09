--
-- PostgreSQL database dump
--

-- Dumped from database version 12.4
-- Dumped by pg_dump version 12.4

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
-- Name: file_fdw; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS file_fdw WITH SCHEMA public;


--
-- Name: EXTENSION file_fdw; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION file_fdw IS 'foreign-data wrapper for flat file access';


--
-- Name: calc_hash(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calc_hash() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
Begin
	New.pass = md5(New.pass);
	Return New;
End
$$;


ALTER FUNCTION public.calc_hash() OWNER TO postgres;

--
-- Name: calc_sum(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calc_sum() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN 
	NEW.s = New.a + New.b;
	RETURN New;
END
$$;


ALTER FUNCTION public.calc_sum() OWNER TO postgres;

--
-- Name: kmeans_classify(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.kmeans_classify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
Declare
        d0 float;
        d1 float;
        cx0 float = 6.2;
        cy0 float = 7.0;
        cx1 float = 2.0;
        cy1 float = 1.8;
begin
        d0 = sqrt((cx0 - NEW.x)*(cx0-NEW.x)+(cy0-NEW.y)*(cy0-NEW.y));
        d1 = sqrt((cx1 - NEW.x)*(cx1-NEW.x)+(cy1-NEW.y)*(cy1-NEW.y));

        If d0 < d1 then
        NEW.z = 0;
        else
        NEW.z = 1;
        End if;

        return NEW;
End
$$;


ALTER FUNCTION public.kmeans_classify() OWNER TO postgres;

--
-- Name: log_event(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.log_event() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
Begin
	insert into logs(evt) values (concat('account"',OLD.usr, '"deleted'));
	return OLD;
End
$$;


ALTER FUNCTION public.log_event() OWNER TO postgres;

--
-- Name: log_nevent(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.log_nevent() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	if OLD.usr = 'admin' then
	insert into logs (evt) values ('an attempt to delete admin account');
	raise notice 'this will be reported';
	return null;
	end if;
	insert into logs (evt) values (concat('account"',OLD.usr,'"deleted'));
	return OLD;
end
$$;


ALTER FUNCTION public.log_nevent() OWNER TO postgres;

--
-- Name: solve_equation(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.solve_equation() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
Declare
	d float;
Begin
	d = NEW.b * NEW.b - 4.0 * NEW.a * NEW.c;
	
	If d <0.0 Then
	return NEW;
	End If;

	If d > 0.0 Then
	New.x0 = (-NEW.b - sqrt(d))/(2.0 * NEW.a);
	New.x1 = (-NEW.b + sqrt(d))/(2.0 * NEW.a);
	Return NEW;
	End If;

	NEW.x0 = -NEW.b / (2.0 * NEW.a);
	Return NEW;
End
$$;


ALTER FUNCTION public.solve_equation() OWNER TO postgres;

--
-- Name: solve_equation_o(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.solve_equation_o() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
Declare
	d float;
Begin
	If TG_OP = 'DELETE' then
	insert into logs (evt) values ('equation deleted');
	return OLD;
	End If;

	d = NEW.b * NEW.b - 4.0 * NEW.a * NEW.c;

	If d <0.0 Then
	return NEW;
	End If;

	If d > 0.0 Then
	New.x0 = (-NEW.b - sqrt(d))/(2.0 * NEW.a);
	New.x1 = (-NEW.b + sqrt(d))/(2.0 * NEW.a);
	Return NEW;
	End If;

	NEW.x0 = -NEW.b / (2.0 * NEW.a);
	Return NEW;
End
$$;


ALTER FUNCTION public.solve_equation_o() OWNER TO postgres;

--
-- Name: file_srv; Type: SERVER; Schema: -; Owner: postgres
--

CREATE SERVER file_srv FOREIGN DATA WRAPPER file_fdw;


ALTER SERVER file_srv OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: accs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.accs (
    usr character varying(10),
    pass character varying(50)
);


ALTER TABLE public.accs OWNER TO postgres;

--
-- Name: kmeans_test; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kmeans_test (
    x double precision,
    y double precision,
    z integer
);


ALTER TABLE public.kmeans_test OWNER TO postgres;

--
-- Name: kmeans_test1; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kmeans_test1 (
    x double precision,
    y double precision,
    z integer
);


ALTER TABLE public.kmeans_test1 OWNER TO postgres;

--
-- Name: logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.logs (
    ts timestamp without time zone DEFAULT now(),
    evt character varying(100)
);


ALTER TABLE public.logs OWNER TO postgres;

--
-- Name: quads; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.quads (
    a double precision,
    b double precision,
    c double precision,
    x0 double precision,
    x1 double precision
);


ALTER TABLE public.quads OWNER TO postgres;

--
-- Name: sums; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sums (
    a integer,
    b integer,
    s integer,
    u integer
);


ALTER TABLE public.sums OWNER TO postgres;

--
-- Name: synth_data; Type: FOREIGN TABLE; Schema: public; Owner: postgres
--

CREATE FOREIGN TABLE public.synth_data (
    x double precision,
    y double precision,
    z integer
)
SERVER file_srv
OPTIONS (
    filename '/home/ilch/synth_data.csv',
    format 'csv'
);


ALTER FOREIGN TABLE public.synth_data OWNER TO postgres;

--
-- Data for Name: accs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.accs (usr, pass) FROM stdin;
admin	d8578edf8458ce06fbc5bb76a58c5ca4
\.


--
-- Data for Name: kmeans_test; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.kmeans_test (x, y, z) FROM stdin;
5.45948911935767	0.510593961775605	1
6.772251034990475	9.088637297244482	0
6.4821767379412165	0.2002628333653078	1
1.4524182654908913	1.6486199141056446	1
9.826620776551067	9.53108452637121	0
7.255503238589327	0.5122068636210386	1
1.8324115448770328	0.4759166024615169	1
3.572234378217942	5.769650455428099	0
8.294811883648379	5.783650451455848	0
2.972891187828921	6.802243694553063	0
8.174576788834287	2.594941221204543	0
2.935196494629153	9.589302159766113	0
9.583128047069067	1.1543823840512957	0
7.330813607764881	3.2276023765063044	0
5.887324547737904	9.406738331755342	0
7.571821776839371	9.652966034504438	0
4.093902982569091	0.9993530904564452	1
5.016274355213071	8.008704119470345	0
2.1268267905513483	1.8537300172854643	1
3.9117307546646174	8.042227130261814	0
8.242289079529996	6.487229305555324	0
7.1241362491824844	4.753115162815682	0
6.833233480933387	4.162810411111728	0
0.869493570910933	6.968402884797378	1
5.1115010957411755	0.7539582433799907	1
4.256567665590367	4.070097425413515	1
4.630847493028654	0.9978282659139026	1
0.6857805632110825	9.51359008813288	0
7.994116752206537	8.167929647834562	0
0.9641276970408086	4.602473685174466	1
2.1950754214232404	1.7552904244416467	1
8.726270795690354	7.05541431654698	0
6.3583136225068415	5.662217387486628	0
2.6420763034480643	2.8254776981625085	1
8.793978992296587	8.874929258116957	0
3.5911627787427136	6.304253808097862	0
9.56893733624895	1.311207723332295	0
9.052136504285855	9.136087792440328	0
3.659517407800905	0.2887302649383727	1
8.35102224019856	5.336787877330416	0
2.29681174113324	8.112124503441116	0
7.0090762882438895	4.992670596802391	0
7.603336580699391	0.9464691430931893	1
3.500092436165332	8.527298091824242	0
6.965717293170428	0.27766466338714935	1
8.453118541072868	2.163589689551948	0
7.864226841294482	4.732760781683929	0
2.306083114822215	4.858228558238729	1
2.814979569579066	5.254160536372403	1
9.123327917399209	0.5047620774782402	0
\.


--
-- Data for Name: kmeans_test1; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.kmeans_test1 (x, y, z) FROM stdin;
6	6	0
7	6	0
5	7	0
7	8	0
6	8	0
3	2	1
4	0	1
3	2	1
0	3	1
0	2	1
\.


--
-- Data for Name: logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.logs (ts, evt) FROM stdin;
2023-05-09 09:41:39.162463	account"test"deleted
2023-05-09 10:06:12.807782	account"abc"deleted
2023-05-09 10:06:47.830031	an attempt to delete admin account
2023-05-09 15:42:33.792953	equation deleted
2023-05-09 15:42:33.792953	equation deleted
\.


--
-- Data for Name: quads; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.quads (a, b, c, x0, x1) FROM stdin;
2	4	3	\N	\N
2	4	2	-1	\N
4	5	6	\N	\N
7	8	2	-0.7734590803390136	-0.3693980625181293
\.


--
-- Data for Name: sums; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sums (a, b, s, u) FROM stdin;
1	2	3	\N
3	4	7	\N
7	8	15	\N
11	12	23	\N
5	6	11	\N
15	16	31	\N
9	10	19	0
17	16	\N	\N
170	180	350	\N
\.


--
-- Name: logs log_protect; Type: RULE; Schema: public; Owner: postgres
--

CREATE RULE log_protect AS
    ON DELETE TO public.logs DO INSTEAD NOTHING;


--
-- Name: kmeans_test kmeans_predict; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER kmeans_predict BEFORE INSERT ON public.kmeans_test FOR EACH ROW EXECUTE FUNCTION public.kmeans_classify();


--
-- Name: accs tg_hash; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tg_hash BEFORE INSERT ON public.accs FOR EACH ROW EXECUTE FUNCTION public.calc_hash();

ALTER TABLE public.accs DISABLE TRIGGER tg_hash;


--
-- Name: accs tg_log; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tg_log BEFORE DELETE ON public.accs FOR EACH ROW EXECUTE FUNCTION public.log_event();

ALTER TABLE public.accs DISABLE TRIGGER tg_log;


--
-- Name: accs tg_log1; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tg_log1 BEFORE DELETE ON public.accs FOR EACH ROW EXECUTE FUNCTION public.log_nevent();


--
-- Name: sums tg_sum; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tg_sum BEFORE INSERT ON public.sums FOR EACH ROW EXECUTE FUNCTION public.calc_sum();

ALTER TABLE public.sums DISABLE TRIGGER tg_sum;


--
-- Name: sums tg_sum1; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tg_sum1 BEFORE INSERT OR UPDATE ON public.sums FOR EACH ROW EXECUTE FUNCTION public.calc_sum();

ALTER TABLE public.sums DISABLE TRIGGER tg_sum1;


--
-- Name: sums tg_sum2; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tg_sum2 BEFORE INSERT OR UPDATE ON public.sums FOR EACH ROW WHEN ((new.a > 100)) EXECUTE FUNCTION public.calc_sum();


--
-- PostgreSQL database dump complete
--

