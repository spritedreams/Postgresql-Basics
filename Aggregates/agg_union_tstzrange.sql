/*
    Create aggregate function to return the union of all the timestamp ranges (tstzrange). [union of all sets]
    Returns an array of tstzranges. If tstzranges are disjointed, then more than one range is returned.
*/
CREATE or replace FUNCTION _agg_union_tstzrange(agg_state tstzrange[],next_val tstzrange)
RETURNS tstzrange[] AS $$
    DECLARE
        t record;
        new_range tstzrange;
        temp tstzrange[];
        prev_range tstzrange;
        disjointed boolean := false;
    BEGIN
        IF next_val is NULL or isempty(next_val) is true 
            THEN RETURN agg_state; 
        END IF;
        IF agg_state is NULL or array_length(agg_state,1) is NULL THEN 
            RETURN array_append(agg_state,next_val); 
        END IF;
        FOR t in SELECT 
                    date_range,
                    case
                        when date_range && next_val or date_range -|- next_val
                            then date_range + next_val
                        else
                           NULL 
                    end new_dt_range
                from unnest(agg_state) as date_range 
                order by date_range 
        LOOP
            if t.new_dt_range is null then
                prev_range := t.date_range;
                temp := array_append(temp,prev_range);
                disjointed := true;
            elseif lower(t.new_dt_range) <= upper(prev_range) then 
                new_range := t.new_dt_range + prev_range;
                temp := array_replace(temp,prev_range,new_range);
                prev_range := new_range;
                disjointed := false;
            else 
                temp := array_append(temp,t.new_dt_range);
                prev_range := t.new_dt_range;
                disjointed := false;
            end if;
        END LOOP;
        if disjointed is true then -- next_val has no overlap
            temp := array_append(temp,next_val);
        end if;
        agg_state := temp;
        RETURN agg_state;
    END;
$$ LANGUAGE plpgsql;
comment on function _agg_union_tstzrange(agg_state tstzrange[],next_val tstzrange) is 'Supporting function for custom aggregate agg_union_tstzrange';

CREATE or replace FUNCTION _final_agg_union_tstzrange(agg_state tstzrange[])
RETURNS tstzrange[] AS $$
    BEGIN
        RETURN agg_state;
    END;
$$ LANGUAGE plpgsql;
comment on function _final_agg_union_tstzrange(agg_state tstzrange[]) is 'Supporting function for custom aggregate agg_union_tstzrange';

CREATE AGGREGATE agg_union_tstzrange(tstzrange) (
    stype = tstzrange[],
    sfunc = _agg_union_tstzrange,
    finalfunc = _final_agg_union_tstzrange
);
comment on aggregate agg_union_tstzrange(tstzrange) is 'Returns set union of all tstzranges in an array - union may be disjointed';
