-- Card ID: 50000004
-- Cyber D'va Eira Error
local s,id=GetID()
local SET_CYBER_DVA=0x5a1
function s.initial_effect(c)
    -- Hand -1 correction
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_HAND)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
    e1:SetCountLimit(1,{id,1})
    e1:SetCondition(s.hcon)
    e1:SetCost(s.hcost)
    e1:SetOperation(s.hop)
    c:RegisterEffect(e1)
    -- Field deficit correction from GY
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
    e2:SetCountLimit(1,{id,2})
    e2:SetCondition(s.gcon)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.gtg)
    e2:SetOperation(s.gop)
    c:RegisterEffect(e2)
end
function s.mainphase()
    local ph=Duel.GetCurrentPhase()
    return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
function s.hcon(e,tp,eg,ep,ev,re,r,rp)
    return s.mainphase() and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)-Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)==1
end
function s.hcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
    Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function s.linkfilter(c)
    return c:IsFaceup() and c:IsSetCard(SET_CYBER_DVA) and c:IsType(TYPE_LINK)
end
function s.bottom1(tp)
    if Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
    if #g>0 then Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT) end
end
function s.hop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.IsExistingMatchingCard(s.linkfilter,tp,LOCATION_MZONE,0,1,nil) and Duel.Draw(tp,1,REASON_EFFECT)>0 then
        s.bottom1(tp)
    end
end
function s.gcon(e,tp,eg,ep,ev,re,r,rp)
    return s.mainphase() and Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)-Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==1
end
function s.thfilter(c)
    return c:IsSetCard(SET_CYBER_DVA) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.gtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.gop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0
        and Duel.IsExistingMatchingCard(s.linkfilter,tp,LOCATION_MZONE,0,1,nil)
        and Duel.Draw(tp,1,REASON_EFFECT)>0 then
        s.bottom1(tp)
    end
end
