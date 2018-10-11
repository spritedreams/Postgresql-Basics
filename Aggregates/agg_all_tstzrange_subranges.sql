/*
    Create aggregate to return array of all unique tstzrange end points in ascending order. 
*/
CREATE or replace FUNCTION _agg_subranges_tstzrange(agg_state tstzrange[],next_val tstzrange)
RETURNS tstzrange[] AS $$
    DECLARE
        tstz tstzrange;
    BEGIN
        if isempty(next_val) is true or next_val is null THEN 
            RETURN agg_state;
        END if;
        tstz := tstzrange( coalesce(lower(next_val),'-infinity'::timestamptz), coalesce(upper(next_val),'infinity'::timestamptz) , '[)');
        IF (tstz = ANY (agg_state)) THEN
            RETURN agg_state;
        ELSE
            RETURN array_append(agg_state,tstz);
        END IF;
    END;
$$ LANGUAGE plpgsql;
comment on function _agg_subranges_tstzrange(agg_state tstzrange[],next_val tstzrange) is 'Supporting function for custom aggregate agg_subranges_tstzrange';

CREATE or replace FUNCTION _final_agg_subranges_tstzrange(agg_state tstzrange[])
RETURNS tstzrange[] AS $$
    DECLARE
        prev_tstz timestamptz := NULL::timestamptz;
        tstz timestamptz;
        result tstzrange[];
    BEGIN
        FOR tstz IN 
            WITH r as (
                SELECT unnest(agg_state) as dt
            )
            SELECT lower(r.dt) as dt
                from r
            UNION
            SELECT upper(r.dt) as dt
                from r
            ORDER BY dt LOOP
            IF prev_tstz is NULL THEN
                prev_tstz := tstz;
            ELSE
                result := array_append(result, tstzrange(prev_tstz,tstz,'[)'));
                prev_tstz := tstz;
            END IF;
        END LOOP;
        RETURN result; 
    END;
$$ LANGUAGE plpgsql;
comment on function _final_agg_subranges_tstzrange(agg_state tstzrange[]) is 'Supporting function for custom aggregate agg_subranges_tstzrange';

--DROP AGGREGATE IF EXISTS agg_subranges_tstzrange(tstzrange);
CREATE AGGREGATE agg_subranges_tstzrange(tstzrange) (
    stype = tstzrange[],
    sfunc = _agg_subranges_tstzrange,
    finalfunc = _final_agg_subranges_tstzrange
);

comment on aggregate agg_subranges_tstzrange(tstzrange) is 'Returns array of all unique,non-overlapping tstzranges based on all existing end points in ascending order. Union of resulting range is continuous.';
