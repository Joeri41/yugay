-- Card ID: 50000005
-- Cyber D'va Mira Cache
local s,id=GetID()
local SET_CYBER_DVA=0x5a1
function s.initial_effect(c)
    -- Foolish on Normal/Special Summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetCountLimit(1,{id,1})
    e1:SetTarget(s.gytg)
    e1:SetOperation(s.gyop)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)
    -- Add itself from GY if field leads hand by exactly 1
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1,{id,2})
    e3:SetCondition(s.selfcon)
    e3:SetTarget(s.selftg)
    e3:SetOperation(s.selfop)
    c:RegisterEffect(e3)
    -- While equal: reveal this card, revive a low-Level Cyber D'va, draw 1
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,2))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_HAND)
    e4:SetCountLimit(1,{id,3})
    e4:SetCondition(s.eqcon)
    e4:SetCost(s.revcost)
    e4:SetTarget(s.sptg)
    e4:SetOperation(s.spop)
    c:RegisterEffect(e4)
end
function s.gyfilter(c)
    return c:IsSetCard(SET_CYBER_DVA) and not c:IsCode(id) and c:IsAbleToGrave()
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.gyfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.gyfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then Duel.SendtoGrave(g,REASON_EFFECT) end
end
function s.selfcon(e,tp,eg,ep,ev,re,r,rp)
    local ph=Duel.GetCurrentPhase()
    return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
        and Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)-Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==1
end
function s.selftg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToHand() end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.selfop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then Duel.SendtoHand(c,nil,REASON_EFFECT) end
end
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
    local ph=Duel.GetCurrentPhase()
    return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
        and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
end
function s.revcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.ConfirmCards(1-tp,e:GetHandler())
end
function s.spfilter(c,e,tp)
    return c:IsSetCard(SET_CYBER_DVA) and c:IsMonster() and c:HasLevel() and c:IsLevelBelow(4)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then Duel.Draw(tp,1,REASON_EFFECT) end
end
