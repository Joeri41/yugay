-- Card ID: 50000011
-- Cyber D'va Crossfade Protocol
local s,id=GetID()
local SET_CYBER_DVA=0x5a1
local COUNTER_RESONANCE=0x15a1

function s.initial_effect(c)
    c:EnableCounterPermit(COUNTER_RESONANCE)
    c:SetUniqueOnField(1,0,id)

    -- Activate Continuous Spell
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)

    -- Count Cyber D'va cards sent from your hand/field to GY by Cyber D'va effects
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_TO_GRAVE)
    e1:SetRange(LOCATION_SZONE)
    e1:SetOperation(s.ctop)
    c:RegisterEffect(e1)

    -- Once per Chain, spend 2 counters to correct the smaller resource pool
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_CHAIN)
    e2:SetCondition(s.actcon)
    e2:SetCost(s.cost)
    e2:SetTarget(s.target)
    e2:SetOperation(s.operation)
    c:RegisterEffect(e2)
end

function s.sentfilter(c,tp,re,r)
    return c:IsControler(tp)
        and c:IsPreviousLocation(LOCATION_HAND|LOCATION_ONFIELD)
        and c:IsSetCard(SET_CYBER_DVA)
        and (r&REASON_EFFECT)~=0
        and re
        and re:GetHandler()
        and re:GetHandler():IsSetCard(SET_CYBER_DVA)
end

function s.ctop(e,tp,eg,ep,ev,re,r,rp)
    local ct=eg:FilterCount(s.sentfilter,nil,tp,re,r)
    if ct>0 then
        e:GetHandler():AddCounter(COUNTER_RESONANCE,ct)
    end
end

function s.diff(tp)
    return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
        - Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
end

function s.thfilter(c)
    return c:IsSetCard(SET_CYBER_DVA)
        and c:IsMonster()
        and c:IsAbleToHand()
end

function s.spfilter(c,e,tp)
    return c:IsSetCard(SET_CYBER_DVA)
        and c:IsMonster()
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.setfilter(c)
    return c:IsSetCard(SET_CYBER_DVA)
        and c:IsSpellTrap()
        and c:IsSSetable()
end

function s.actcon(e,tp,eg,ep,ev,re,r,rp)
    if e:GetHandler():GetCounter(COUNTER_RESONANCE)<2 then
        return false
    end
    local d=s.diff(tp)
    if d<0 then
        return Duel.IsExistingMatchingCard(
            aux.NecroValleyFilter(s.thfilter),
            tp,LOCATION_GRAVE,0,1,nil
        )
    end
    if d>0 then
        return
            (Duel.GetLocationCount(tp,LOCATION_MZONE)>0
                and Duel.IsExistingMatchingCard(
                    aux.NecroValleyFilter(s.spfilter),
                    tp,LOCATION_GRAVE,0,1,nil,e,tp
                ))
            or Duel.IsExistingMatchingCard(
                aux.NecroValleyFilter(s.setfilter),
                tp,LOCATION_GRAVE,0,1,nil
            )
    end
    return false
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return e:GetHandler():IsCanRemoveCounter(
            tp,COUNTER_RESONANCE,2,REASON_COST
        )
    end
    e:GetHandler():RemoveCounter(
        tp,COUNTER_RESONANCE,2,REASON_COST
    )
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local d=s.diff(tp)

    if d<0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g=Duel.SelectMatchingCard(
            tp,
            aux.NecroValleyFilter(s.thfilter),
            tp,LOCATION_GRAVE,0,1,1,nil
        )
        if #g>0 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
        end

    elseif d>0 then
        local can_sp=
            Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(
                aux.NecroValleyFilter(s.spfilter),
                tp,LOCATION_GRAVE,0,1,nil,e,tp
            )

        local can_set=
            Duel.IsExistingMatchingCard(
                aux.NecroValleyFilter(s.setfilter),
                tp,LOCATION_GRAVE,0,1,nil
            )

        if not can_sp and not can_set then return end

        local op
        if can_sp and can_set then
            op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
        elseif can_sp then
            op=0
        else
            op=1
        end

        if op==0 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local g=Duel.SelectMatchingCard(
                tp,
                aux.NecroValleyFilter(s.spfilter),
                tp,LOCATION_GRAVE,0,1,1,nil,e,tp
            )
            if #g>0 then
                Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
            end
        else
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
            local g=Duel.SelectMatchingCard(
                tp,
                aux.NecroValleyFilter(s.setfilter),
                tp,LOCATION_GRAVE,0,1,1,nil
            )
            if #g>0 then
                Duel.SSet(tp,g)
            end
        end
    end
end
