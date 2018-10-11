/*
    Create aggregate to return array of all unique tstzrange end points in ascending order. 
*/
CREATE or replace FUNCTION _agg_endpoints_tstzrange(agg_state timestamptz[],next_val tstzrange)
RETURNS timestamptz[] AS $$
    BEGIN
        if isempty(next_val) is true or next_val is null THEN 
            RETURN agg_state;
        END if;
        agg_state := array_append(agg_state,coalesce(lower(next_val),'-infinity'::timestamptz));
        agg_state := array_append(agg_state,coalesce(upper(next_val),'infinity'::timestamptz));
        RETURN agg_state;
    END;
$$ LANGUAGE plpgsql;
comment on function _agg_endpoints_tstzrange(agg_state timestamptz[],next_val tstzrange) is 'Supporting function for custom aggregate agg_endpoints_tstzrange';

CREATE or replace FUNCTION _final_agg_endpoints_tstzrange(agg_state timestamptz[])
RETURNS timestamptz[] AS $$
    BEGIN
        RETURN array(SELECT distinct unnest(agg_state) order by 1)::timestamptz[];
    END;
$$ LANGUAGE plpgsql;
comment on function _final_agg_endpoints_tstzrange(agg_state timestamptz[]) is 'Supporting function for custom aggregate agg_endpoints_tstzrange';

--DROP AGGREGATE IF EXISTS agg_endpoints_tstzrange(tstzrange);
CREATE AGGREGATE agg_endpoints_tstzrange(tstzrange) (
    stype = timestamptz[],
    sfunc = _agg_endpoints_tstzrange,
    finalfunc = _final_agg_endpoints_tstzrange
);

comment on aggregate agg_endpoints_tstzrange(tstzrange) is 'Returns array of all unique tstzrange end points in ascending order';
