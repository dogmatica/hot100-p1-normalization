/* Create database and table to accommodate data import from csv */

CREATE DATABASE top100data
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;
	
	
	
CREATE TABLE public.hot100
(
    chart_position integer,
    chart_date date,
    song character varying,
    performer character varying,
    song_id character varying,
    instance integer DEFAULT 0,
    time_on_chart integer DEFAULT 0,
    consecutive_weeks integer DEFAULT 0,
    previous_week integer DEFAULT 0,
    peak_position integer DEFAULT 0,
    worst_position integer DEFAULT 0,
    chart_debut date,
    chart_url character varying
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.hot100
    OWNER to postgres;
	
	
	
/* data import from csv
command " "\\copy public.hot100 (chart_position, chart_date, song, performer, song_id, 
instance, time_on_chart, consecutive_weeks, previous_week, peak_position, worst_position, 
chart_debut, chart_url) FROM 'C:/Users/wstul/DOWNLO~1/HOT100~1.CSV' DELIMITER ',' 
CSV HEADER ENCODING 'UTF8';""
 */



/* View imported table data */
SELECT chart_position, chart_date, song, performer, song_id, instance, time_on_chart, consecutive_weeks, previous_week, peak_position, worst_position, chart_debut, chart_url
	FROM public.hot100;
	
	
/* Getting the number of unique song_id */
SELECT COUNT (DISTINCT song_id) FROM public.hot100;
"30444"

/* Testing unique song_id with best (MIN) peak_position */
SELECT DISTINCT song_id song, MIN(peak_position) peak
FROM public.hot100
GROUP BY song_id;


/* checking for non-UTF8 characters in song_id */

SELECT * FROM public.hot100
WHERE LENGTH(song_id) <> CHAR_LENGTH(song_id)


/* Normalization process begins here.  Splitting imported data into 3 tables linked by song_id:
hot100_chart - song_id, peak, worst, weeks, time_on
hot100_song - song_id, performer, song
hot100_date - song_id, chart_date, chart_debut, chart_url */

CREATE TABLE public.hot100_chart
AS
SELECT DISTINCT song_id, MIN(peak_position) peak, MAX(worst_position) worst, 
MAX(consecutive_weeks) weeks, MAX(time_on_chart) time_on
FROM public.hot100
GROUP BY song_id;

ALTER TABLE IF EXISTS public.hot100_chart
    ADD PRIMARY KEY (song_id);
		
CREATE TABLE public.hot100_song
AS
SELECT DISTINCT song_id, performer, song
FROM public.hot100;

ALTER TABLE IF EXISTS public.hot100_song
    ADD FOREIGN KEY (song_id)
    REFERENCES public.hot100_chart (song_id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE
    NOT VALID;
		
CREATE TABLE public.hot100_date
AS
SELECT DISTINCT song_id, chart_date, chart_debut, chart_url
FROM public.hot100;

ALTER TABLE IF EXISTS public.hot100_date
    ADD FOREIGN KEY (song_id)
    REFERENCES public.hot100_chart (song_id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE
    NOT VALID;