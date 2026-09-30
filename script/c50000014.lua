-- Card ID: 50000014
-- Cyber D'va Duet - Parallax Halo
local s,id=GetID()
local SET_CYBER_DVA=0x5a1
function s.initial_effect(c)
    Link.AddProcedure(c,s.matfilter,2,2)
    c:EnableReviveLimit()
    -- Set a Quick-Play Spell or Counter Trap from Deck on Link Summon
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
    -- Perfect Sync disruption
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DISABLE+CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1,{id,2})
    e2:SetCondition(s.eqcon)
    e2:SetTarget(s.negtg)
    e2:SetOperation(s.negop)
    c:RegisterEffect(e2)
end
function s.matfilter(c,lc,sumtype,tp)
    return c:IsSetCard(SET_CYBER_DVA)
end
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.setfilter(c)
    return c:IsSetCard(SET_CYBER_DVA) and c:IsSSetable()
        and (c:IsType(TYPE_QUICKPLAY) or c:IsType(TYPE_COUNTER))
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
    local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then Duel.SSet(tp,g) end
end
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
end
function s.negfilter(c)
    return c:IsFaceup() and not c:IsDisabled()
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_ONFIELD) and s.negfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.negfilter,tp,0,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
    Duel.SelectTarget(tp,s.negfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
end
function s.gybanfilter(c)
    return c:IsSetCard(SET_CYBER_DVA) and c:IsAbleToRemove()
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
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
    if Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.gybanfilter),tp,LOCATION_GRAVE,0,1,nil)
        and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
        local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.gybanfilter),tp,LOCATION_GRAVE,0,1,1,nil)
        if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 and tc:IsRelateToEffect(e) then
            Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)
        end
    end
end
