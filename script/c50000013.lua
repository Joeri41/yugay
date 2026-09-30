-- Card ID: 50000013
-- Cyber D'va Soloist - Echo Zero
local s,id=GetID()
local SET_CYBER_DVA=0x5a1
local STAGE_ID=50000008
function s.initial_effect(c)
    Link.AddProcedure(c,s.matfilter,1,1)
    c:EnableReviveLimit()
    -- Search the Field Spell on Link Summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1,{id,1})
    e1:SetCondition(s.thcon)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)
    -- Recycle when used as Link Material for a Cyber D'va monster
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetCountLimit(1,{id,2})
    e2:SetCondition(s.reccon)
    e2:SetTarget(s.rectg)
    e2:SetOperation(s.recop)
    c:RegisterEffect(e2)
end
function s.matfilter(c,lc,sumtype,tp)
    return c:IsSetCard(SET_CYBER_DVA) and c:IsMonster() and c:HasLevel() and c:IsLevelBelow(4)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.stagefilter(c)
    return c:IsCode(STAGE_ID) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.stagefilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.stagefilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end
function s.reccon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local rc=c:GetReasonCard()
    return c:IsReason(REASON_LINK) and rc and rc:IsSetCard(SET_CYBER_DVA)
end
function s.recfilter(c)
    return c:IsSetCard(SET_CYBER_DVA) and c:IsMonster() and c:IsAbleToHand()
end
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.recfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.recop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.recfilter),tp,LOCATION_GRAVE,0,1,1,nil)
    if #g==0 or Duel.SendtoHand(g,nil,REASON_EFFECT)==0 then return end
    if Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
        local bg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
        if #bg>0 then Duel.SendtoDeck(bg,nil,SEQ_DECKBOTTOM,REASON_EFFECT) end
    end
end
