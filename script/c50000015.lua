-- Card ID: 50000015
-- Cyber D'va Triune - Black Chorus
local s,id=GetID()
local SET_CYBER_DVA=0x5a1
function s.initial_effect(c)
    Link.AddProcedure(c,s.matfilter,2,3)
    c:EnableReviveLimit()
    -- Set Cyber D'va backrow from GY on Link Summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1,{id,1})
    e1:SetCondition(s.setcon)
    e1:SetTarget(s.settg)
    e1:SetOperation(s.setop)
    c:RegisterEffect(e1)
    -- Perfect Sync destruction protection
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(LOCATION_ONFIELD,0)
    e2:SetCondition(s.eqcon)
    e2:SetTarget(s.indtg)
    e2:SetValue(1)
    c:RegisterEffect(e2)
    -- Omni-negate fueled from GY
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_CHAINING)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,{id,2})
    e3:SetCondition(s.negcon)
    e3:SetCost(s.negcost)
    e3:SetTarget(s.negtg)
    e3:SetOperation(s.negop)
    c:RegisterEffect(e3)
end
function s.matfilter(c,lc,sumtype,tp)
    return c:IsSetCard(SET_CYBER_DVA)
end
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.setfilter(c)
    return c:IsSetCard(SET_CYBER_DVA) and c:IsSpellTrap() and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.setfilter),tp,LOCATION_GRAVE,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then Duel.SSet(tp,g) end
end
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
end
function s.indtg(e,c)
    return c:IsSetCard(SET_CYBER_DVA)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return rp==1-tp and Duel.IsChainNegatable(ev)
end
function s.costfilter(c)
    return c:IsSetCard(SET_CYBER_DVA) and c:IsAbleToRemoveAsCost()
end
function s.chlimit(e,rp,tp)
    return tp==rp
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.costfilter),tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.costfilter),tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.Remove(g,POS_FACEUP,REASON_COST)
    if Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0) then
        Duel.SetChainLimit(s.chlimit)
    end
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) then
        local rc=re:GetHandler()
        if rc:IsRelateToEffect(re) then Duel.Remove(rc,POS_FACEUP,REASON_EFFECT) end
    end
end
