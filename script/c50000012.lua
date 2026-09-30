-- Card ID: 50000012
-- Cyber D'va Dead Air
local s,id=GetID()
function s.initial_effect(c)
    -- Negate an opponent's inherent Special Summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_SPSUMMON)
    e1:SetCountLimit(1,{id,1})
    e1:SetCondition(s.spnegcon)
    e1:SetTarget(s.spnegtg)
    e1:SetOperation(s.spnegop)
    c:RegisterEffect(e1)
    -- Negate an opponent's card/effect activation
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_ACTIVATE)
    e2:SetCode(EVENT_CHAINING)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.actnegcon)
    e2:SetTarget(s.actnegtg)
    e2:SetOperation(s.actnegop)
    c:RegisterEffect(e2)
    -- Re-Set itself after resolving if it restores Perfect Sync
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetCountLimit(1,{id,2})
    e3:SetCondition(s.resetcon)
    e3:SetTarget(s.resettg)
    e3:SetOperation(s.resetop)
    c:RegisterEffect(e3)
end
function s.eq(tp)
    return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
end
function s.mark(c)
    c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD_EXC_GRAVE,0,1)
end
function s.spnegcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetCurrentChain()==0 and ep==1-tp and Duel.IsSummonNegatable(eg) and s.eq(tp)
end
function s.spnegtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    s.mark(e:GetHandler())
    Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,#eg,0,0)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,#eg,0,0)
end
function s.spnegop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateSummon(eg) then Duel.Remove(eg,POS_FACEDOWN,REASON_EFFECT) end
end
function s.actnegcon(e,tp,eg,ep,ev,re,r,rp)
    return rp==1-tp and Duel.IsChainNegatable(ev) and s.eq(tp)
end
function s.actnegtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    s.mark(e:GetHandler())
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.actnegop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) then
        local rc=re:GetHandler()
        if rc:IsRelateToEffect(re) then Duel.Remove(rc,POS_FACEDOWN,REASON_EFFECT) end
    end
end
function s.resetcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:GetFlagEffect(id)>0 and c:IsPreviousLocation(LOCATION_SZONE)
        and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)-Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)==1
end
function s.resettg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsSSetable() end
end
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.SSet(tp,c)>0 then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetReset(RESET_EVENT|RESETS_REDIRECT)
        e1:SetValue(LOCATION_REMOVED)
        c:RegisterEffect(e1,true)
    end
end
