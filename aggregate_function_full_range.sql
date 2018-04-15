/*
Create aggregate function. Returns the full range (smallest and largest endpoints) for range timestamp type.
*/
CREATE FUNCTION _agg_full_range_tstzrange(tstzrange,tstzrange)
RETURNS tstzrange AS $$
    BEGIN
        RETURN tstzrange(least(lower($1),lower($2)),greatest(upper($1),upper($2)));
    END;
$$ LANGUAGE plpgsql;

CREATE AGGREGATE agg_full_range_tstzrange(tstzrange) (
    sfunc = _agg_full_range_tstzrange,
    stype = tstzrange
);
