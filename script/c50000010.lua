-- Card ID: 50000010
-- Cyber D'va Debut Upload
local s,id=GetID()
local SET_CYBER_DVA=0x5a1
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end
function s.sendfilter(c)
    return c:IsSetCard(SET_CYBER_DVA) and c:IsMonster() and c:IsAbleToGrave()
end
function s.addfilter(c,code)
    return c:IsSetCard(SET_CYBER_DVA) and c:IsMonster() and not c:IsCode(code) and c:IsAbleToHand()
end
function s.canresolve(tp)
    local g=Duel.GetMatchingGroup(s.sendfilter,tp,LOCATION_DECK,0,nil)
    for tc in g:Iter() do
        if Duel.IsExistingMatchingCard(s.addfilter,tp,LOCATION_DECK,0,1,tc,tc:GetCode()) then return true end
    end
    return false
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return s.canresolve(tp) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.setfilter(c)
    return c:IsSetCard(SET_CYBER_DVA) and c:IsSpellTrap() and not c:IsCode(id) and c:IsSSetable()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local sg=Duel.SelectMatchingCard(tp,s.sendfilter,tp,LOCATION_DECK,0,1,1,nil)
    local sc=sg:GetFirst()
    if not sc or Duel.SendtoGrave(sc,REASON_EFFECT)==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local ag=Duel.SelectMatchingCard(tp,s.addfilter,tp,LOCATION_DECK,0,1,1,nil,sc:GetCode())
    if #ag==0 or Duel.SendtoHand(ag,nil,REASON_EFFECT)==0 then return end
    Duel.ConfirmCards(1-tp,ag)
    if Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
        and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
        and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
        local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
        if #g>0 then Duel.SSet(tp,g) end
    end
end
