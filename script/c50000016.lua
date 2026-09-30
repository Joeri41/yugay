-- Card ID: 50000016
-- Cyber D'va Headliner - Event Horizon
local s,id=GetID()
local SET_CYBER_DVA=0x5a1
function s.initial_effect(c)
    Link.AddProcedure(c,s.matfilter,2,4,s.lcheck)
    c:EnableReviveLimit()
    -- Revive a Cyber D'va on Link Summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1,{id,1})
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    -- Perfect Sync: opponent's cards sent to GY are banished instead
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_TO_GRAVE_REDIRECT)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(0,LOCATION_ALL)
    e2:SetCondition(s.eqcon)
    e2:SetValue(LOCATION_REMOVED)
    c:RegisterEffect(e2)
    -- Once per Chain interaction
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_TODECK)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_CHAINING)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id,EFFECT_COUNT_CODE_CHAIN)
    e3:SetCondition(s.intcon)
    e3:SetCost(s.intcost)
    e3:SetTarget(s.inttg)
    e3:SetOperation(s.intop)
    c:RegisterEffect(e3)
end
function s.matfilter(c,lc,sumtype,tp)
    return c:IsSetCard(SET_CYBER_DVA)
end
function s.linkmat(c)
    return c:IsType(TYPE_LINK)
end
function s.lcheck(g,lc,sumtype,tp)
    return g:IsExists(s.linkmat,1,nil)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.spfilter(c,e,tp)
    return c:IsSetCard(SET_CYBER_DVA) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g>0 then Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) end
end
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
end
function s.intcon(e,tp,eg,ep,ev,re,r,rp)
    return rp==1-tp
end
function s.costfilter(c)
    return c:IsSetCard(SET_CYBER_DVA) and c:IsAbleToRemoveAsCost()
end
function s.intcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.costfilter),tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.costfilter),tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.tdfilter(c)
    return c:IsAbleToDeck()
end
function s.inttg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,0,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    Duel.SelectTarget(tp,s.tdfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
end
function s.intop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT) end
end
