-- Card ID: 50000008
-- Cyber D'va Stage - Neon Event Horizon
local s,id=GetID()
local SET_CYBER_DVA=0x5a1
function s.initial_effect(c)
    -- Activation search
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)
    -- Once per Chain: trim the larger resource pool by one
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_FZONE)
    e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_CHAIN)
    e2:SetCondition(s.fixcon)
    e2:SetTarget(s.fixtg)
    e2:SetOperation(s.fixop)
    c:RegisterEffect(e2)
    -- Perfect Sync target protection
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e3:SetRange(LOCATION_FZONE)
    e3:SetTargetRange(LOCATION_ONFIELD,0)
    e3:SetCondition(s.eqcon)
    e3:SetTarget(s.tglimit)
    e3:SetValue(aux.tgoval)
    c:RegisterEffect(e3)
end
function s.monfilter(c)
    return c:IsSetCard(SET_CYBER_DVA) and c:IsMonster() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.monfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.monfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end
function s.eq(tp)
    return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
end
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
    return s.eq(tp)
end
function s.fixcon(e,tp,eg,ep,ev,re,r,rp)
    return not s.eq(tp)
end
function s.handfilter(c)
    return c:IsSetCard(SET_CYBER_DVA) and c:IsAbleToGrave()
end
function s.fieldfilter(c)
    return c:IsSetCard(SET_CYBER_DVA) and c:IsAbleToGrave()
end
function s.fixtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local h=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
    local f=Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
    if chk==0 then
        if h>f then return Duel.IsExistingMatchingCard(s.handfilter,tp,LOCATION_HAND,0,1,nil) end
        return Duel.IsExistingMatchingCard(s.fieldfilter,tp,LOCATION_ONFIELD,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND|LOCATION_ONFIELD)
end
function s.bottom1(tp)
    if Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
    if #g>0 then Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT) end
end
function s.fixop(e,tp,eg,ep,ev,re,r,rp)
    local h=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
    local f=Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
    local g
    if h>f then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        g=Duel.SelectMatchingCard(tp,s.handfilter,tp,LOCATION_HAND,0,1,1,nil)
    elseif f>h then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        g=Duel.SelectMatchingCard(tp,s.fieldfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
    else
        return
    end
    if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 and s.eq(tp) then
        if Duel.Draw(tp,1,REASON_EFFECT)>0 then s.bottom1(tp) end
    end
end
function s.tglimit(e,c)
    return c:IsSetCard(SET_CYBER_DVA)
end
