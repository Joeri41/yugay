-- Card ID: 50000006
-- Cyber D'va Vexa Loop
local s,id=GetID()
local SET_CYBER_DVA=0x5a1
function s.initial_effect(c)
    -- Special Summon itself if hand leads by 2+
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,{id,1})
    e1:SetCondition(s.spcon)
    c:RegisterEffect(e1)
    -- Send Cyber D'va from Deck to GY, optionally return a banished one to GY
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOGRAVE)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetCountLimit(1,{id,2})
    e2:SetTarget(s.gytg)
    e2:SetOperation(s.gyop)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)
    -- Perfect Sync: negate, steal until End Phase, then draw to preserve count
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,2))
    e4:SetCategory(CATEGORY_DISABLE+CATEGORY_CONTROL+CATEGORY_DRAW)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_MZONE)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e4:SetCountLimit(1,{id,3})
    e4:SetCondition(s.eqcon)
    e4:SetTarget(s.cttg)
    e4:SetOperation(s.ctop)
    c:RegisterEffect(e4)
end
function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)-Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)>=2
end
function s.gyfilter(c)
    return c:IsSetCard(SET_CYBER_DVA) and c:IsAbleToGrave()
end
function s.rmfilter(c)
    return c:IsFaceup() and c:IsSetCard(SET_CYBER_DVA) and c:IsAbleToGrave()
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.gyfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.gyfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g==0 or Duel.SendtoGrave(g,REASON_EFFECT)==0 then return end
    if Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_REMOVED,0,1,nil)
        and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        local rg=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_REMOVED,0,1,1,nil)
        if #rg>0 then Duel.SendtoGrave(rg,REASON_EFFECT+REASON_RETURN) end
    end
end
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
end
function s.ctfilter(c)
    return c:IsFaceup() and not c:IsDisabled() and c:IsControlerCanBeChanged()
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.ctfilter(chkc) end
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(s.ctfilter,tp,0,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    Duel.SelectTarget(tp,s.ctfilter,tp,0,LOCATION_MZONE,1,1,nil)
end
function s.linkgy(c)
    return c:IsSetCard(SET_CYBER_DVA) and c:IsType(TYPE_LINK)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e) and tc:IsFaceup()) then return end
    Duel.NegateRelatedChain(tc,RESET_TURN_SET)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_DISABLE)
    e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
    tc:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_DISABLE_EFFECT)
    tc:RegisterEffect(e2)
    if Duel.IsExistingMatchingCard(s.linkgy,tp,LOCATION_GRAVE,0,1,nil)
        and tc:IsControlerCanBeChanged() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.GetControl(tc,tp,PHASE_END,1)>0 then
        Duel.Draw(tp,1,REASON_EFFECT)
    end
end
