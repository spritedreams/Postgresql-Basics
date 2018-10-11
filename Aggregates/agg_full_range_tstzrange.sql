/*
Create aggregate function. Returns the full range (smallest and largest endpoints) for tstzrange type.
*/
CREATE or replace FUNCTION _agg_full_range_tstzrange(tstzrange,tstzrange)
RETURNS tstzrange AS $$
    BEGIN
        CASE 
            WHEN $1 IS NULL OR isempty($1) IS TRUE THEN
                RETURN $2;
            WHEN $2 IS NULL OR isempty($2) IS TRUE THEN
                RETURN $1;
            ELSE
                RETURN tstzrange(
                        least(coalesce(lower($1),'-infinity'::timestamptz),coalesce(lower($2),'-infinity'::timestamptz)),
                        greatest(coalesce(upper($1),'infinity'::timestamptz),coalesce(upper($2),'infinity'::timestamptz)),
                        '[)'
                );
        END CASE;
    END;
$$ LANGUAGE plpgsql;
comment on function _agg_full_range_tstzrange(tstzrange,tstzrange) is 'Supporting function for custom aggregate aggregate agg_full_range_tstzrange';

--DROP AGGREGATE IF EXISTS agg_full_range_tstzrange(tstzrange);
CREATE AGGREGATE agg_full_range_tstzrange(tstzrange) (
    sfunc = _agg_full_range_tstzrange,
    stype = tstzrange
);
comment on aggregate agg_full_range_tstzrange(tstzrange) is 'Returns tstzrange where the end points are the absolute min and max of all the tstzranges';
