// onboarding.jsx — 7-step onboarding flow
// Full-bleed, iOS-native feel. Pinned footer with Back/Continue. Progress dots at top.

const GOAL_OPTIONS = [
  { id: 'strong',   icon: 'dumbbell', label: 'Feel stronger',        sub: 'Build strength, slowly' },
  { id: 'move',     icon: 'figure',   label: 'Move more',             sub: 'Walking, stretching, anything' },
  { id: 'steady',   icon: 'heart',    label: 'Feel more steady',      sub: 'Mood, energy, sleep' },
  { id: 'reflect',  icon: 'book',     label: 'Reflect on my days',    sub: 'Short journal, no pressure' },
  { id: 'rhythm',   icon: 'sun',      label: 'Find a rhythm',         sub: 'A gentle daily routine' },
  { id: 'recover',  icon: 'leaf',     label: 'Come back to myself',   sub: 'After a break or a hard season' },
];

const HABIT_TEMPLATES = [
  { id: 'walk',    icon: 'figure',   title: 'Morning walk',        sub: '20 minutes · any pace',         cat: 'Movement',  recommended: true },
  { id: 'push',    icon: 'dumbbell', title: 'Strength · Push',     sub: '3 × per week · 35 min',         cat: 'Strength' },
  { id: 'stretch', icon: 'leaf',     title: 'Stretch & breathe',   sub: '8 min · mobility + breath',     cat: 'Mobility',  recommended: true },
  { id: 'journal', icon: 'book',     title: 'Evening journal',     sub: 'One line. One feeling.',        cat: 'Reflect',   recommended: true },
  { id: 'water',   icon: 'sun',      title: 'Drink water',         sub: 'A little more than yesterday',  cat: 'Care' },
  { id: 'sleep',   icon: 'moon',     title: 'Wind-down hour',      sub: 'Phone down, lights low',        cat: 'Care' },
];

const TIME_OPTIONS = [
  { id: 'morning',   icon: 'sun',   label: 'Mornings',   sub: 'Before the day gets loud' },
  { id: 'afternoon', icon: 'sun',   label: 'Afternoons', sub: 'Lunch-adjacent, or post-work' },
  { id: 'evening',   icon: 'moon',  label: 'Evenings',   sub: 'When things settle down' },
  { id: 'flexible',  icon: 'heart', label: 'Flexible',   sub: "I'll tell you later" },
];

function OnboardingFlow({ t, onComplete }) {
  const [step, setStep] = React.useState(0);
  const [name, setName] = React.useState('');
  const [goals, setGoals] = React.useState([]);
  const [habits, setHabits] = React.useState(['walk', 'journal', 'stretch']);
  const [timePref, setTimePref] = React.useState(null);
  const [notifsChoice, setNotifsChoice] = React.useState(null);

  const steps = [
    'welcome', 'name', 'goals', 'habits', 'time', 'notifs', 'done'
  ];
  const currentKey = steps[step];
  const totalSteps = steps.length;

  const canContinue = () => {
    switch (currentKey) {
      case 'welcome': return true;
      case 'name':    return true; // optional
      case 'goals':   return goals.length > 0;
      case 'habits':  return habits.length >= 1 && habits.length <= 4;
      case 'time':    return timePref !== null;
      case 'notifs':  return notifsChoice !== null;
      case 'done':    return true;
      default: return true;
    }
  };

  const continueLabel = () => {
    if (currentKey === 'welcome') return 'Let\u2019s begin';
    if (currentKey === 'name')    return name ? `Hi, ${name}` : 'Skip for now';
    if (currentKey === 'done')    return 'Start your first day';
    return 'Continue';
  };

  const toggle = (arr, setter, id, max = Infinity) => {
    if (arr.includes(id)) setter(arr.filter(x => x !== id));
    else if (arr.length < max) setter([...arr, id]);
  };

  const next = () => {
    if (currentKey === 'done') { onComplete && onComplete({ name, goals, habits, timePref, notifsChoice }); return; }
    if (!canContinue()) return;
    setStep(s => Math.min(s + 1, steps.length - 1));
  };
  const back = () => setStep(s => Math.max(s - 1, 0));

  return (
    <div style={{
      height: '100%', display: 'flex', flexDirection: 'column',
      background: t.color.bg,
      position: 'relative',
    }}>
      {/* Top: progress dots + back */}
      <div style={{
        padding: '50px 20px 0',
        display: 'flex', alignItems: 'center', minHeight: 54,
      }}>
        {step > 0 && currentKey !== 'done' ? (
          <button onClick={back} style={{
            width: 34, height: 34, borderRadius: 17, border: 'none', cursor: 'pointer',
            background: t.color.surfaceCard, boxShadow: t.elev.sm,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>
            <Icon name="chevronLeft" size={18} color={t.color.primary} strokeWidth={2.4}/>
          </button>
        ) : <div style={{ width: 34 }}/>}

        <div style={{ flex: 1, display: 'flex', justifyContent: 'center', gap: 6 }}>
          {steps.map((_, i) => (
            <div key={i} style={{
              width: i === step ? 20 : 6, height: 6, borderRadius: 3,
              background: i === step ? t.color.primary : i < step ? t.color.primaryMuted : t.color.border,
              transition: 'all 260ms cubic-bezier(0.34, 1.2, 0.64, 1)',
            }}/>
          ))}
        </div>

        <div style={{ width: 34 }}/>
      </div>

      {/* Content — keyed so it re-mounts for fade-in */}
      <div key={step} style={{
        flex: 1, overflow: 'auto',
        animation: 'mmFade 340ms ease-out',
      }}>
        {currentKey === 'welcome' && <StepWelcome t={t}/>}
        {currentKey === 'name'    && <StepName    t={t} name={name} setName={setName}/>}
        {currentKey === 'goals'   && <StepGoals   t={t} goals={goals} setGoals={setGoals}/>}
        {currentKey === 'habits'  && <StepHabits  t={t} habits={habits} setHabits={setHabits} toggle={toggle}/>}
        {currentKey === 'time'    && <StepTime    t={t} value={timePref} setValue={setTimePref}/>}
        {currentKey === 'notifs'  && <StepNotifs  t={t} choice={notifsChoice} setChoice={setNotifsChoice} name={name}/>}
        {currentKey === 'done'    && <StepDone    t={t} name={name} habits={habits}/>}
      </div>

      {/* Footer CTA */}
      <div style={{
        padding: '12px 20px 28px',
        background: `linear-gradient(to top, ${t.color.bg} 60%, ${t.color.bg}00)`,
      }}>
        <button onClick={next} disabled={!canContinue()}
          style={{
            width: '100%', padding: '16px', borderRadius: t.radius.pill,
            border: 'none', cursor: canContinue() ? 'pointer' : 'default',
            background: canContinue() ? t.color.primary : t.color.border,
            color: canContinue() ? t.color.onPrimary : t.color.textTertiary,
            fontFamily: t.family.rounded, fontSize: 17, fontWeight: 700,
            letterSpacing: -0.2,
            boxShadow: canContinue() ? t.elev.md : 'none',
            transition: 'all 200ms cubic-bezier(0.34, 1.2, 0.64, 1)',
          }}>
          {continueLabel()}
        </button>
        {currentKey !== 'welcome' && currentKey !== 'done' && (
          <button onClick={() => onComplete && onComplete({ skipped: true })}
            style={{
              width: '100%', marginTop: 10, padding: '10px',
              border: 'none', background: 'transparent', cursor: 'pointer',
              color: t.color.textSecondary, fontFamily: t.family.text,
              fontSize: 14, fontWeight: 500,
            }}>
            Skip setup — I'll explore on my own
          </button>
        )}
      </div>
    </div>
  );
}

// ── Step: Welcome ──────────────────────────────────────────

function StepWelcome({ t }) {
  return (
    <div style={{
      padding: '20px 24px 40px', textAlign: 'center',
      display: 'flex', flexDirection: 'column', alignItems: 'center',
      justifyContent: 'center', minHeight: '88%',
    }}>
      {/* Soft sunrise mark */}
      <div style={{ position: 'relative', width: 160, height: 160, marginBottom: 32 }}>
        <div style={{
          position: 'absolute', inset: 0,
          borderRadius: '50%',
          background: `radial-gradient(circle at 50% 55%, ${t.color.primary}, ${t.color.primaryTint} 55%, transparent 75%)`,
          animation: 'mmFade 900ms ease-out',
        }}/>
        <div style={{
          position: 'absolute', left: '50%', top: '50%',
          transform: 'translate(-50%, -50%)',
          width: 64, height: 64, borderRadius: 32,
          background: t.color.primary,
          boxShadow: `0 12px 32px ${t.color.primary}40`,
        }}/>
        {/* Horizon line */}
        <div style={{
          position: 'absolute', left: 10, right: 10, bottom: 36,
          height: 1, background: t.color.secondary, opacity: 0.35,
        }}/>
      </div>

      <div style={{ ...typeStyle(t.type.caption2, t.family), color: t.color.textTertiary,
        textTransform: 'uppercase', letterSpacing: 1.2, marginBottom: 12 }}>
        MotivateMe
      </div>
      <div style={{
        fontFamily: t.family.serif || t.family.rounded,
        fontSize: 34, fontWeight: 600, lineHeight: 1.15,
        color: t.color.textPrimary, letterSpacing: -0.4,
        fontStyle: t.family.serif ? 'italic' : 'normal',
        maxWidth: 280, textWrap: 'balance',
      }}>
        A little better,<br/>most days.
      </div>
      <div style={{
        ...typeStyle(t.type.body, t.family),
        color: t.color.textSecondary, marginTop: 14,
        maxWidth: 300, textWrap: 'balance', lineHeight: 1.45,
      }}>
        This app is a quiet companion for the small habits that add up. No streaks lost, no shaming, no noise.
      </div>
    </div>
  );
}

// ── Step: Name ─────────────────────────────────────────────

function StepName({ t, name, setName }) {
  return (
    <div style={{ padding: '24px 24px 40px' }}>
      <div style={{ ...typeStyle(t.type.largeTitle, t.family),
        color: t.color.textPrimary, letterSpacing: -0.8 }}>
        What should I call you?
      </div>
      <div style={{ ...typeStyle(t.type.body, t.family), color: t.color.textSecondary,
        marginTop: 8, lineHeight: 1.45 }}>
        I'll use it when I check in. Just a first name is perfect — or whatever feels like you.
      </div>

      <div style={{ marginTop: 28, padding: '16px 18px', borderRadius: 16,
        background: t.color.surfaceCard, boxShadow: t.elev.sm,
        display: 'flex', alignItems: 'center', gap: 10,
      }}>
        <div style={{ width: 28, height: 28, borderRadius: 14,
          background: t.color.primaryMuted,
          display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <Icon name="person" size={16} color={t.color.primary}/>
        </div>
        <input
          value={name} onChange={e => setName(e.target.value)}
          placeholder="Your name"
          style={{
            flex: 1, border: 'none', outline: 'none', background: 'transparent',
            fontFamily: t.family.rounded, fontSize: 20, fontWeight: 500,
            color: t.color.textPrimary,
          }}
        />
      </div>

      <div style={{ marginTop: 14, padding: '12px 16px', borderRadius: 14,
        background: t.color.secondaryTint,
        display: 'flex', gap: 10, alignItems: 'flex-start' }}>
        <Icon name="leaf" size={14} color={t.color.secondary}/>
        <div style={{ ...typeStyle(t.type.footnote, t.family), color: t.color.textSecondary,
          lineHeight: 1.4 }}>
          Nothing leaves your phone unless you turn on backup. This is just between us.
        </div>
      </div>
    </div>
  );
}

// ── Step: Goals ────────────────────────────────────────────

function StepGoals({ t, goals, setGoals }) {
  const toggle = (id) => {
    setGoals(goals.includes(id) ? goals.filter(x => x !== id) : [...goals, id]);
  };
  return (
    <div style={{ padding: '24px 24px 40px' }}>
      <div style={{ ...typeStyle(t.type.largeTitle, t.family),
        color: t.color.textPrimary, letterSpacing: -0.8 }}>
        What brings you here?
      </div>
      <div style={{ ...typeStyle(t.type.body, t.family), color: t.color.textSecondary,
        marginTop: 8, lineHeight: 1.45 }}>
        Pick any that feel true. You can change your mind anytime.
      </div>

      <div style={{ display: 'flex', flexDirection: 'column', gap: 8, marginTop: 22 }}>
        {GOAL_OPTIONS.map(g => {
          const selected = goals.includes(g.id);
          return (
            <button key={g.id} onClick={() => toggle(g.id)}
              style={{
                padding: '14px 16px', borderRadius: 16, cursor: 'pointer',
                background: selected ? t.color.primaryTint : t.color.surfaceCard,
                border: selected ? `1.5px solid ${t.color.primary}` : `1.5px solid transparent`,
                boxShadow: t.elev.xs,
                display: 'flex', alignItems: 'center', gap: 14, textAlign: 'left',
                transition: 'all 200ms cubic-bezier(0.34, 1.2, 0.64, 1)',
              }}>
              <div style={{
                width: 40, height: 40, borderRadius: 12, flexShrink: 0,
                background: selected ? t.color.primary : t.color.primaryMuted,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                transition: 'background 200ms',
              }}>
                <Icon name={g.icon} size={18}
                  color={selected ? t.color.onPrimary : t.color.primary}/>
              </div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ ...typeStyle(t.type.callout, t.family),
                  color: t.color.textPrimary, fontWeight: 600 }}>
                  {g.label}
                </div>
                <div style={{ ...typeStyle(t.type.footnote, t.family),
                  color: t.color.textSecondary, marginTop: 1 }}>
                  {g.sub}
                </div>
              </div>
              <div style={{
                width: 22, height: 22, borderRadius: 11,
                background: selected ? t.color.primary : 'transparent',
                border: selected ? 'none' : `1.5px solid ${t.color.border}`,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                flexShrink: 0,
              }}>
                {selected && <Icon name="check" size={14} color={t.color.onPrimary} strokeWidth={3}/>}
              </div>
            </button>
          );
        })}
      </div>
    </div>
  );
}

// ── Step: Habits ───────────────────────────────────────────

function StepHabits({ t, habits, setHabits, toggle }) {
  return (
    <div style={{ padding: '24px 24px 40px' }}>
      <div style={{ ...typeStyle(t.type.largeTitle, t.family),
        color: t.color.textPrimary, letterSpacing: -0.8 }}>
        Start small.
      </div>
      <div style={{ ...typeStyle(t.type.body, t.family), color: t.color.textSecondary,
        marginTop: 8, lineHeight: 1.45 }}>
        Pick 1–4 things you'd like to do most days. Less is more — we can always add later.
      </div>

      {/* Counter */}
      <div style={{ marginTop: 16, display: 'flex', alignItems: 'center', gap: 8 }}>
        <div style={{
          padding: '4px 10px', borderRadius: t.radius.pill,
          background: habits.length > 4 ? t.color.warning || t.color.primary : t.color.primaryTint,
          ...typeStyle(t.type.caption1, t.family), fontWeight: 600,
          color: t.color.primary,
        }}>
          {habits.length} selected
        </div>
        {habits.length > 4 && (
          <span style={{ ...typeStyle(t.type.caption1, t.family), color: t.color.textSecondary,
            fontStyle: 'italic' }}>
            Maybe start with a few
          </span>
        )}
      </div>

      <div style={{ display: 'flex', flexDirection: 'column', gap: 8, marginTop: 16 }}>
        {HABIT_TEMPLATES.map(h => {
          const selected = habits.includes(h.id);
          return (
            <button key={h.id} onClick={() => toggle(habits, setHabits, h.id)}
              style={{
                padding: '12px 14px', borderRadius: 16, cursor: 'pointer',
                background: selected ? t.color.primaryTint : t.color.surfaceCard,
                border: selected ? `1.5px solid ${t.color.primary}` : `1.5px solid transparent`,
                boxShadow: t.elev.xs,
                display: 'flex', alignItems: 'center', gap: 12, textAlign: 'left',
                transition: 'all 200ms cubic-bezier(0.34, 1.2, 0.64, 1)',
              }}>
              <div style={{
                width: 36, height: 36, borderRadius: 10, flexShrink: 0,
                background: selected ? t.color.primary : `color-mix(in oklab, ${t.color.primary} 10%, ${t.color.surfaceCard})`,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
              }}>
                <Icon name={h.icon} size={16}
                  color={selected ? t.color.onPrimary : t.color.primary}/>
              </div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                  <div style={{ ...typeStyle(t.type.callout, t.family),
                    color: t.color.textPrimary, fontWeight: 600 }}>
                    {h.title}
                  </div>
                  {h.recommended && !selected && (
                    <span style={{
                      padding: '1px 6px', borderRadius: 6,
                      background: t.color.secondaryTint,
                      ...typeStyle(t.type.caption2, t.family),
                      color: t.color.secondary, fontWeight: 600,
                      textTransform: 'uppercase', letterSpacing: 0.5,
                    }}>
                      Gentle start
                    </span>
                  )}
                </div>
                <div style={{ ...typeStyle(t.type.caption1, t.family),
                  color: t.color.textSecondary, marginTop: 1 }}>
                  {h.sub}
                </div>
              </div>
              <div style={{
                width: 22, height: 22, borderRadius: 11,
                background: selected ? t.color.primary : 'transparent',
                border: selected ? 'none' : `1.5px solid ${t.color.border}`,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                flexShrink: 0,
              }}>
                {selected && <Icon name="check" size={14} color={t.color.onPrimary} strokeWidth={3}/>}
              </div>
            </button>
          );
        })}
      </div>
    </div>
  );
}

// ── Step: Time preference ──────────────────────────────────

function StepTime({ t, value, setValue }) {
  return (
    <div style={{ padding: '24px 24px 40px' }}>
      <div style={{ ...typeStyle(t.type.largeTitle, t.family),
        color: t.color.textPrimary, letterSpacing: -0.8 }}>
        When works for you?
      </div>
      <div style={{ ...typeStyle(t.type.body, t.family), color: t.color.textSecondary,
        marginTop: 8, lineHeight: 1.45 }}>
        This shapes when we check in — a reminder, not a leash.
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10, marginTop: 24 }}>
        {TIME_OPTIONS.map(opt => {
          const selected = value === opt.id;
          return (
            <button key={opt.id} onClick={() => setValue(opt.id)}
              style={{
                padding: '18px 14px', borderRadius: 18, cursor: 'pointer',
                background: selected ? t.color.primaryTint : t.color.surfaceCard,
                border: selected ? `1.5px solid ${t.color.primary}` : `1.5px solid transparent`,
                boxShadow: t.elev.xs,
                display: 'flex', flexDirection: 'column', alignItems: 'flex-start', gap: 10,
                textAlign: 'left',
                transition: 'all 200ms cubic-bezier(0.34, 1.2, 0.64, 1)',
              }}>
              <div style={{
                width: 40, height: 40, borderRadius: 12,
                background: selected ? t.color.primary : `color-mix(in oklab, ${t.color.primary} 12%, ${t.color.surfaceCard})`,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
              }}>
                <Icon name={opt.icon} size={18}
                  color={selected ? t.color.onPrimary : t.color.primary}/>
              </div>
              <div>
                <div style={{ ...typeStyle(t.type.headline, t.family),
                  color: t.color.textPrimary }}>
                  {opt.label}
                </div>
                <div style={{ ...typeStyle(t.type.caption1, t.family),
                  color: t.color.textSecondary, marginTop: 2, lineHeight: 1.35 }}>
                  {opt.sub}
                </div>
              </div>
            </button>
          );
        })}
      </div>
    </div>
  );
}

// ── Step: Notifications ────────────────────────────────────

function StepNotifs({ t, choice, setChoice, name }) {
  return (
    <div style={{ padding: '24px 24px 40px' }}>
      <div style={{ ...typeStyle(t.type.largeTitle, t.family),
        color: t.color.textPrimary, letterSpacing: -0.8 }}>
        A gentle nudge{name ? `, ${name}` : ''}?
      </div>
      <div style={{ ...typeStyle(t.type.body, t.family), color: t.color.textSecondary,
        marginTop: 8, lineHeight: 1.45 }}>
        We send one morning check-in and optional reminders for habits you set. Nothing else.
      </div>

      {/* Simulated notification preview */}
      <div style={{
        marginTop: 22, padding: '14px 14px', borderRadius: 18,
        background: `color-mix(in oklab, ${t.color.textPrimary} 6%, ${t.color.surfaceCard})`,
      }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
          <div style={{
            width: 36, height: 36, borderRadius: 10,
            background: t.color.primary,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>
            <Icon name="sun" size={18} color={t.color.onPrimary}/>
          </div>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline' }}>
              <span style={{ ...typeStyle(t.type.footnote, t.family),
                color: t.color.textSecondary, fontWeight: 600 }}>
                MotivateMe
              </span>
              <span style={{ ...typeStyle(t.type.caption1, t.family), color: t.color.textTertiary }}>
                8:00 AM
              </span>
            </div>
            <div style={{ ...typeStyle(t.type.subhead, t.family),
              color: t.color.textPrimary, fontWeight: 600, marginTop: 2 }}>
              {name ? `Morning, ${name}` : 'Morning'}
            </div>
            <div style={{ ...typeStyle(t.type.footnote, t.family),
              color: t.color.textSecondary, marginTop: 1 }}>
              One-minute check-in to shape today.
            </div>
          </div>
        </div>
      </div>

      <div style={{ ...typeStyle(t.type.caption1, t.family), color: t.color.textTertiary,
        textAlign: 'center', marginTop: 10, fontStyle: 'italic' }}>
        Example — you'll see the real iOS prompt next
      </div>

      <div style={{ display: 'flex', flexDirection: 'column', gap: 8, marginTop: 22 }}>
        <NotifChoice t={t} selected={choice === 'on'}
          onClick={() => setChoice('on')}
          title="Yes, send gentle nudges"
          sub="Morning check-in + the reminders you set"/>
        <NotifChoice t={t} selected={choice === 'off'}
          onClick={() => setChoice('off')}
          title="Not right now"
          sub="You can turn them on anytime in Settings"/>
      </div>
    </div>
  );
}

function NotifChoice({ t, selected, onClick, title, sub }) {
  return (
    <button onClick={onClick} style={{
      padding: '14px 16px', borderRadius: 16, cursor: 'pointer',
      background: selected ? t.color.primaryTint : t.color.surfaceCard,
      border: selected ? `1.5px solid ${t.color.primary}` : `1.5px solid transparent`,
      boxShadow: t.elev.xs, textAlign: 'left',
      display: 'flex', alignItems: 'center', gap: 12,
      transition: 'all 200ms cubic-bezier(0.34, 1.2, 0.64, 1)',
    }}>
      <div style={{
        width: 22, height: 22, borderRadius: 11, flexShrink: 0,
        background: selected ? t.color.primary : 'transparent',
        border: selected ? 'none' : `1.5px solid ${t.color.border}`,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
      }}>
        {selected && <div style={{ width: 8, height: 8, borderRadius: 4, background: t.color.onPrimary }}/>}
      </div>
      <div>
        <div style={{ ...typeStyle(t.type.callout, t.family),
          color: t.color.textPrimary, fontWeight: 600 }}>
          {title}
        </div>
        <div style={{ ...typeStyle(t.type.footnote, t.family),
          color: t.color.textSecondary, marginTop: 1 }}>
          {sub}
        </div>
      </div>
    </button>
  );
}

// ── Step: Done ─────────────────────────────────────────────

function StepDone({ t, name, habits }) {
  const count = habits.length;
  return (
    <div style={{
      padding: '20px 24px 40px', textAlign: 'center',
      display: 'flex', flexDirection: 'column', alignItems: 'center',
      justifyContent: 'center', minHeight: '88%',
    }}>
      {/* Animated check circle */}
      <div style={{
        position: 'relative', width: 128, height: 128, marginBottom: 28,
      }}>
        <div style={{
          position: 'absolute', inset: 0, borderRadius: '50%',
          background: `radial-gradient(circle, ${t.color.primary}30, transparent 70%)`,
          animation: 'mmFade 800ms ease-out',
        }}/>
        <div style={{
          position: 'absolute', left: '50%', top: '50%',
          transform: 'translate(-50%, -50%)',
          width: 84, height: 84, borderRadius: 42,
          background: t.color.primary,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          boxShadow: `0 18px 40px ${t.color.primary}50`,
          animation: 'mmPop 620ms cubic-bezier(0.34, 1.4, 0.64, 1)',
        }}>
          <Icon name="check" size={40} color={t.color.onPrimary} strokeWidth={3}/>
        </div>
      </div>

      <div style={{
        fontFamily: t.family.serif || t.family.rounded,
        fontSize: 30, fontWeight: 600, lineHeight: 1.2,
        color: t.color.textPrimary, letterSpacing: -0.4,
        fontStyle: t.family.serif ? 'italic' : 'normal',
        maxWidth: 280, textWrap: 'balance',
      }}>
        {name ? `You're in, ${name}.` : "You're all set."}
      </div>
      <div style={{
        ...typeStyle(t.type.body, t.family),
        color: t.color.textSecondary, marginTop: 14,
        maxWidth: 300, textWrap: 'balance', lineHeight: 1.45,
      }}>
        {count} {count === 1 ? 'habit' : 'habits'} to start with. Today counts as day one.
      </div>

      <div style={{
        marginTop: 28, padding: '14px 18px', borderRadius: 16,
        background: t.color.secondaryTint,
        display: 'flex', alignItems: 'center', gap: 12,
      }}>
        <Icon name="leaf" size={16} color={t.color.secondary}/>
        <div style={{ ...typeStyle(t.type.footnote, t.family),
          color: t.color.textPrimary, textAlign: 'left', lineHeight: 1.4 }}>
          Miss a day? Nothing breaks. We pick up where you left off — that's kind of the point.
        </div>
      </div>
    </div>
  );
}

Object.assign(window, { OnboardingFlow });
