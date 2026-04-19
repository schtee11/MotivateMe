// logger.jsx — Active workout logger
// Focused, calm, one-set-at-a-time flow. Rest timer with ring, set rows, finish sheet.

const WORKOUT_TEMPLATE = {
  id: 'w-push',
  title: 'Upper body — Push',
  subtitle: 'Pre-filled from last week',
  category: 'Strength',
  exercises: [
    { id: 'e1', name: 'Barbell bench press', muscle: 'Chest',
      sets: [
        { target: '8 × 135', prev: '8 × 135', weight: 135, reps: 8, done: true },
        { target: '8 × 155', prev: '8 × 155', weight: 155, reps: 8, done: true },
        { target: '5 × 185', prev: '5 × 180', weight: 185, reps: null, done: false, current: true },
        { target: '5 × 185', prev: '5 × 180', weight: 185, reps: null, done: false },
        { target: 'AMRAP × 165', prev: '7 × 165', weight: 165, reps: null, done: false },
      ],
      rest: 120 },
    { id: 'e2', name: 'Incline DB press', muscle: 'Upper chest',
      sets: [
        { target: '10 × 50', prev: '10 × 50', weight: 50, reps: null, done: false },
        { target: '10 × 50', prev: '10 × 50', weight: 50, reps: null, done: false },
        { target: '10 × 50', prev: '10 × 50', weight: 50, reps: null, done: false },
      ],
      rest: 90 },
    { id: 'e3', name: 'Overhead press', muscle: 'Shoulders',
      sets: [
        { target: '8 × 95', prev: '8 × 95', weight: 95, reps: null, done: false },
        { target: '8 × 95', prev: '8 × 95', weight: 95, reps: null, done: false },
        { target: '8 × 95', prev: '7 × 95', weight: 95, reps: null, done: false },
      ],
      rest: 120 },
    { id: 'e4', name: 'Lateral raises', muscle: 'Shoulders',
      sets: [
        { target: '12 × 20', prev: '12 × 20', weight: 20, reps: null, done: false },
        { target: '12 × 20', prev: '12 × 20', weight: 20, reps: null, done: false },
        { target: '12 × 20', prev: '12 × 20', weight: 20, reps: null, done: false },
      ],
      rest: 60 },
    { id: 'e5', name: 'Triceps pushdown', muscle: 'Triceps',
      sets: [
        { target: '12 × 50', prev: '12 × 50', weight: 50, reps: null, done: false },
        { target: '12 × 50', prev: '12 × 50', weight: 50, reps: null, done: false },
        { target: '12 × 50', prev: '12 × 50', weight: 50, reps: null, done: false },
      ],
      rest: 60 },
  ]
};

function formatMS(totalSec) {
  const m = Math.floor(totalSec / 60);
  const s = Math.abs(totalSec) % 60;
  return `${m}:${s.toString().padStart(2, '0')}`;
}

function LoggerScreen({ t, onExit }) {
  const [workout, setWorkout] = React.useState(WORKOUT_TEMPLATE);
  const [activeExerciseIdx, setActiveExerciseIdx] = React.useState(0);
  const [elapsed, setElapsed] = React.useState(14 * 60 + 22); // mid-session feel
  const [rest, setRest] = React.useState(null); // null | { remaining, total, exId, setIdx }
  const [finishOpen, setFinishOpen] = React.useState(false);

  // Session timer
  React.useEffect(() => {
    const h = setInterval(() => setElapsed(x => x + 1), 1000);
    return () => clearInterval(h);
  }, []);

  // Rest timer
  React.useEffect(() => {
    if (!rest) return;
    if (rest.remaining <= -10) { setRest(null); return; }
    const h = setTimeout(() => setRest(r => r && ({ ...r, remaining: r.remaining - 1 })), 1000);
    return () => clearTimeout(h);
  }, [rest]);

  const activeEx = workout.exercises[activeExerciseIdx];

  // Totals
  const totalSets = workout.exercises.reduce((a, e) => a + e.sets.length, 0);
  const doneSets = workout.exercises.reduce((a, e) => a + e.sets.filter(s => s.done).length, 0);

  const markSetDone = (setIdx, patch) => {
    const newExercises = workout.exercises.map((e, i) => {
      if (i !== activeExerciseIdx) return e;
      const newSets = e.sets.map((s, j) => {
        if (j === setIdx) return { ...s, ...patch, done: true, current: false };
        // promote next set to current
        if (j === setIdx + 1 && !s.done) return { ...s, current: true };
        return s;
      });
      return { ...e, sets: newSets };
    });
    setWorkout({ ...workout, exercises: newExercises });
    // Start rest
    setRest({ remaining: activeEx.rest, total: activeEx.rest, exId: activeEx.id, setIdx });
  };

  const goToNextExercise = () => {
    // Find next exercise with incomplete sets
    const next = workout.exercises.findIndex((e, i) => i > activeExerciseIdx && e.sets.some(s => !s.done));
    if (next >= 0) setActiveExerciseIdx(next);
  };

  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', background: t.color.bg }}>
      {/* Compact status header */}
      <div style={{
        padding: '50px 16px 8px',
        display: 'flex', alignItems: 'center', gap: 10,
      }}>
        <button onClick={() => setFinishOpen(true)} style={{
          width: 34, height: 34, borderRadius: 17, border: 'none', cursor: 'pointer',
          background: t.color.surfaceCard, boxShadow: t.elev.sm,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <Icon name="chevronDown" size={18} color={t.color.primary} strokeWidth={2.2}/>
        </button>

        <div style={{ flex: 1 }}>
          <div style={{ ...typeStyle(t.type.caption2, t.family), color: t.color.textTertiary,
            textTransform: 'uppercase', letterSpacing: 0.8 }}>
            Active session
          </div>
          <div style={{ ...typeStyle(t.type.headline, t.family), color: t.color.textPrimary, marginTop: 1 }}>
            {workout.title}
          </div>
        </div>

        <div style={{
          display: 'flex', alignItems: 'center', gap: 6,
          padding: '7px 12px', borderRadius: t.radius.pill,
          background: t.color.surfaceCard, boxShadow: t.elev.sm,
        }}>
          <div style={{ width: 8, height: 8, borderRadius: 4, background: t.color.primary,
            animation: 'mmFade 1.4s ease-in-out infinite alternate' }}/>
          <span style={{ fontFamily: t.family.mono, fontSize: 14, fontWeight: 600,
            color: t.color.textPrimary, letterSpacing: 0.4 }}>
            {formatMS(elapsed)}
          </span>
        </div>
      </div>

      {/* Overall progress bar */}
      <div style={{ padding: '0 16px 6px' }}>
        <div style={{
          height: 4, background: t.color.border, borderRadius: 2, overflow: 'hidden',
        }}>
          <div style={{
            width: `${(doneSets / totalSets) * 100}%`, height: '100%',
            background: `linear-gradient(90deg, ${t.color.primary}, ${t.color.secondary})`,
            transition: 'width 320ms cubic-bezier(0.34, 1.2, 0.64, 1)',
          }}/>
        </div>
        <div style={{ ...typeStyle(t.type.caption1, t.family), color: t.color.textTertiary,
          marginTop: 4, display: 'flex', justifyContent: 'space-between' }}>
          <span>{doneSets} of {totalSets} sets</span>
          <span style={{ fontFamily: t.family.mono }}>{Math.round((doneSets/totalSets)*100)}%</span>
        </div>
      </div>

      {/* Scrollable body */}
      <div style={{ flex: 1, overflow: 'auto', padding: '12px 16px 120px' }}>

        {/* Exercise chips row */}
        <div style={{
          display: 'flex', gap: 8, overflowX: 'auto', padding: '2px 0 10px',
          WebkitOverflowScrolling: 'touch', scrollbarWidth: 'none',
        }}>
          {workout.exercises.map((e, i) => {
            const done = e.sets.every(s => s.done);
            const active = i === activeExerciseIdx;
            return (
              <button key={e.id} onClick={() => setActiveExerciseIdx(i)}
                style={{
                  flex: '0 0 auto', display: 'flex', alignItems: 'center', gap: 6,
                  padding: '7px 12px', borderRadius: t.radius.pill, cursor: 'pointer',
                  border: active ? 'none' : `1px solid ${t.color.border}`,
                  background: active ? t.color.primary : (done ? t.color.secondaryTint : 'transparent'),
                  color: active ? t.color.onPrimary : (done ? t.color.secondary : t.color.textSecondary),
                  fontFamily: t.family.rounded, fontSize: 13, fontWeight: 600,
                  transition: 'all 160ms cubic-bezier(0.34, 1.2, 0.64, 1)',
                }}>
                <span style={{
                  width: 16, height: 16, borderRadius: 8,
                  background: active ? 'rgba(255,255,255,0.28)' : (done ? t.color.secondary : t.color.border),
                  color: active ? t.color.onPrimary : t.color.onPrimary,
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  fontSize: 10, fontWeight: 700,
                }}>
                  {done ? '✓' : (i + 1)}
                </span>
                <span>{e.name.split(' ').slice(0, 2).join(' ')}</span>
              </button>
            );
          })}
        </div>

        {/* Current exercise card */}
        <div style={{
          padding: 18, borderRadius: t.radius.card,
          background: t.color.surfaceCard, boxShadow: t.elev.md,
        }}>
          <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', marginBottom: 2 }}>
            <span style={{ ...typeStyle(t.type.caption2, t.family), color: t.color.textTertiary,
              textTransform: 'uppercase', letterSpacing: 0.8 }}>
              Exercise {activeExerciseIdx + 1} of {workout.exercises.length}
            </span>
            <button style={{ border: 'none', background: 'transparent', cursor: 'pointer', padding: 2,
              display: 'flex', alignItems: 'center', gap: 4,
              fontFamily: t.family.rounded, fontSize: 13, fontWeight: 600, color: t.color.primary }}>
              <Icon name="timer" size={14} color={t.color.primary}/>
              {activeEx.rest}s rest
            </button>
          </div>
          <div style={{ ...typeStyle(t.type.title2, t.family), color: t.color.textPrimary, letterSpacing: -0.4 }}>
            {activeEx.name}
          </div>
          <div style={{ ...typeStyle(t.type.subhead, t.family), color: t.color.textSecondary, marginTop: 2 }}>
            {activeEx.muscle}
          </div>

          {/* Sets header */}
          <div style={{ display: 'grid',
            gridTemplateColumns: '28px 1fr 1fr 44px',
            gap: 10, marginTop: 18, marginBottom: 6,
            ...typeStyle(t.type.caption2, t.family), color: t.color.textTertiary,
            textTransform: 'uppercase', letterSpacing: 0.7 }}>
            <span>Set</span>
            <span>Previous</span>
            <span>Weight × reps</span>
            <span style={{ textAlign: 'right' }}>Done</span>
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
            {activeEx.sets.map((s, j) => (
              <SetRow key={j} t={t} s={s} idx={j}
                onComplete={(reps) => markSetDone(j, { reps })}/>
            ))}
          </div>

          {/* Add set */}
          <button style={{
            width: '100%', marginTop: 10, padding: '10px 12px',
            borderRadius: 12, border: `1px dashed ${t.color.border}`,
            background: 'transparent', cursor: 'pointer',
            color: t.color.primary, fontFamily: t.family.rounded, fontSize: 14, fontWeight: 600,
            display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 6,
          }}>
            <Icon name="plus" size={14} color={t.color.primary} strokeWidth={2.4}/>
            Add set
          </button>
        </div>

        {/* Exercise note */}
        <button style={{
          marginTop: 12, width: '100%', padding: '14px 16px',
          borderRadius: t.radius.card, background: t.color.surfaceCard, boxShadow: t.elev.sm,
          border: 'none', cursor: 'pointer', textAlign: 'left',
          display: 'flex', alignItems: 'center', gap: 12,
        }}>
          <div style={{
            width: 32, height: 32, borderRadius: 10,
            background: t.color.primaryMuted,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>
            <Icon name="book" size={16} color={t.color.primary}/>
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ ...typeStyle(t.type.callout, t.family), color: t.color.textPrimary, fontWeight: 600 }}>
              Note for this set
            </div>
            <div style={{ ...typeStyle(t.type.caption1, t.family), color: t.color.textSecondary, marginTop: 1 }}>
              Form cue, how it felt, anything you want to remember
            </div>
          </div>
          <Icon name="chevronRight" size={14} color={t.color.textTertiary}/>
        </button>

        {/* Next exercise preview */}
        {activeExerciseIdx < workout.exercises.length - 1 && (
          <button onClick={goToNextExercise} style={{
            marginTop: 12, width: '100%', padding: '14px 16px',
            borderRadius: t.radius.card, background: t.color.secondaryTint,
            border: 'none', cursor: 'pointer', textAlign: 'left',
            display: 'flex', alignItems: 'center', gap: 12,
          }}>
            <div style={{ flex: 1 }}>
              <div style={{ ...typeStyle(t.type.caption2, t.family), color: t.color.secondary,
                textTransform: 'uppercase', letterSpacing: 0.8, fontWeight: 700 }}>
                Up next
              </div>
              <div style={{ ...typeStyle(t.type.callout, t.family), color: t.color.textPrimary,
                fontWeight: 600, marginTop: 2 }}>
                {workout.exercises[activeExerciseIdx + 1].name}
              </div>
              <div style={{ ...typeStyle(t.type.caption1, t.family), color: t.color.textSecondary, marginTop: 1 }}>
                {workout.exercises[activeExerciseIdx + 1].sets.length} sets
              </div>
            </div>
            <Icon name="chevronRight" size={16} color={t.color.secondary} strokeWidth={2.2}/>
          </button>
        )}

        <div style={{ marginTop: 18, textAlign: 'center', ...typeStyle(t.type.footnote, t.family),
          color: t.color.textTertiary, fontStyle: 'italic', fontFamily: t.family.serif || t.family.rounded }}>
          You're doing the work. That's the whole thing.
        </div>
      </div>

      {/* Rest timer overlay */}
      {rest && <RestBar t={t} rest={rest}
        onDismiss={() => setRest(null)}
        onAdjust={(delta) => setRest(r => r && ({ ...r, remaining: r.remaining + delta }))}/>}

      {/* Finish sheet */}
      {finishOpen && (
        <FinishSheet t={t} workout={workout} elapsed={elapsed} doneSets={doneSets} totalSets={totalSets}
          onCancel={() => setFinishOpen(false)}
          onFinish={() => { setFinishOpen(false); onExit && onExit(); }}/>
      )}
    </div>
  );
}

// ── Set row ────────────────────────────────────────────────

function SetRow({ t, s, idx, onComplete }) {
  const [weight, setWeight] = React.useState(s.weight);
  const [reps, setReps] = React.useState(s.reps || '');
  const bg = s.done ? t.color.secondaryTint
    : s.current ? `color-mix(in oklab, ${t.color.primary} 8%, ${t.color.surfaceCard})`
    : t.color.surfaceCard;
  const border = s.current ? `1.5px solid ${t.color.primary}` : `1px solid ${t.color.border}`;

  return (
    <div style={{
      display: 'grid', gridTemplateColumns: '28px 1fr 1fr 44px',
      gap: 10, alignItems: 'center',
      padding: '10px 10px', borderRadius: 12,
      background: bg, border,
    }}>
      {/* Set index */}
      <div style={{
        width: 24, height: 24, borderRadius: 12,
        background: s.done ? t.color.secondary : s.current ? t.color.primary : t.color.border,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        fontFamily: t.family.rounded, fontSize: 12, fontWeight: 700,
        color: s.done || s.current ? t.color.onPrimary : t.color.textSecondary,
      }}>
        {idx + 1}
      </div>

      {/* Previous */}
      <div style={{ fontFamily: t.family.mono, fontSize: 13, color: t.color.textTertiary, letterSpacing: 0.2 }}>
        {s.prev}
      </div>

      {/* Entry */}
      <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
        <input
          type="text" inputMode="decimal" value={weight}
          onChange={e => setWeight(e.target.value)}
          disabled={s.done}
          style={{
            width: 48, border: 'none', outline: 'none',
            background: s.done ? 'transparent' : t.color.surfaceCard,
            borderRadius: 8, padding: '5px 8px',
            fontFamily: t.family.mono, fontSize: 15, fontWeight: 600,
            color: s.done ? t.color.textSecondary : t.color.textPrimary,
            textAlign: 'right',
          }}/>
        <span style={{ color: t.color.textTertiary, fontSize: 13 }}>×</span>
        <input
          type="text" inputMode="numeric" value={reps}
          onChange={e => setReps(e.target.value)}
          placeholder="—" disabled={s.done}
          style={{
            width: 40, border: 'none', outline: 'none',
            background: s.done ? 'transparent' : t.color.surfaceCard,
            borderRadius: 8, padding: '5px 8px',
            fontFamily: t.family.mono, fontSize: 15, fontWeight: 600,
            color: s.done ? t.color.textSecondary : t.color.textPrimary,
            textAlign: 'center',
          }}/>
      </div>

      {/* Done checkbox */}
      <button
        onClick={() => !s.done && reps && onComplete(reps)}
        disabled={s.done || !reps}
        style={{
          justifySelf: 'end',
          width: 32, height: 32, borderRadius: 10, cursor: s.done || !reps ? 'default' : 'pointer',
          border: 'none',
          background: s.done ? t.color.secondary : reps ? t.color.primary : t.color.border,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          transition: 'all 180ms cubic-bezier(0.34, 1.2, 0.64, 1)',
          animation: s.done ? 'mmPop 380ms cubic-bezier(0.34, 1.2, 0.64, 1)' : 'none',
        }}>
        {s.done ? (
          <Icon name="check" size={16} color={t.color.onPrimary} strokeWidth={3}/>
        ) : (
          <Icon name="check" size={16} color={reps ? t.color.onPrimary : t.color.textTertiary} strokeWidth={3}/>
        )}
      </button>
    </div>
  );
}

// ── Rest Bar ────────────────────────────────────────────────

function RestBar({ t, rest, onDismiss, onAdjust }) {
  const pct = Math.max(0, Math.min(1, rest.remaining / rest.total));
  const isOvertime = rest.remaining < 0;
  const color = isOvertime ? t.color.secondary : t.color.primary;

  return (
    <div style={{
      position: 'absolute', left: 12, right: 12, bottom: 20,
      padding: 14, borderRadius: t.radius.card,
      background: t.color.surfaceElevated, boxShadow: t.elev.lg,
      display: 'flex', alignItems: 'center', gap: 14,
      animation: 'mmSlideUp 320ms cubic-bezier(0.34, 1.2, 0.64, 1)',
    }}>
      {/* Ring */}
      <div style={{ position: 'relative', width: 56, height: 56, flexShrink: 0 }}>
        <svg width="56" height="56" style={{ transform: 'rotate(-90deg)' }}>
          <circle cx="28" cy="28" r="24" fill="none" stroke={t.color.border} strokeWidth="4"/>
          <circle cx="28" cy="28" r="24" fill="none" stroke={color} strokeWidth="4"
            strokeDasharray={2 * Math.PI * 24}
            strokeDashoffset={2 * Math.PI * 24 * (1 - pct)}
            strokeLinecap="round"
            style={{ transition: 'stroke-dashoffset 900ms linear' }}/>
        </svg>
        <div style={{
          position: 'absolute', inset: 0, display: 'flex', alignItems: 'center', justifyContent: 'center',
          fontFamily: t.family.mono, fontSize: 14, fontWeight: 700, color: t.color.textPrimary,
          letterSpacing: 0.2,
        }}>
          {isOvertime ? '+' : ''}{formatMS(Math.abs(rest.remaining))}
        </div>
      </div>

      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ ...typeStyle(t.type.caption2, t.family), color: t.color.textTertiary,
          textTransform: 'uppercase', letterSpacing: 0.8 }}>
          {isOvertime ? 'Ready when you are' : 'Rest'}
        </div>
        <div style={{ ...typeStyle(t.type.callout, t.family), color: t.color.textPrimary,
          fontWeight: 600, marginTop: 1 }}>
          {isOvertime ? 'Take your time' : 'Breathe, then go again'}
        </div>
      </div>

      {/* Adjust buttons */}
      <div style={{ display: 'flex', gap: 6 }}>
        <button onClick={() => onAdjust(-15)}
          style={{ width: 36, height: 36, borderRadius: 10, border: 'none',
            background: t.color.surfaceCard, cursor: 'pointer',
            fontFamily: t.family.mono, fontSize: 11, fontWeight: 700,
            color: t.color.textSecondary }}>
          −15
        </button>
        <button onClick={onDismiss}
          style={{ width: 36, height: 36, borderRadius: 10, border: 'none',
            background: color, cursor: 'pointer',
            display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <Icon name="check" size={16} color={t.color.onPrimary} strokeWidth={3}/>
        </button>
      </div>
    </div>
  );
}

// ── Finish sheet ────────────────────────────────────────────

function FinishSheet({ t, workout, elapsed, doneSets, totalSets, onCancel, onFinish }) {
  const totalVolume = workout.exercises.reduce((a, e) =>
    a + e.sets.filter(s => s.done).reduce((b, s) => b + (Number(s.weight) || 0) * (Number(s.reps) || 0), 0)
  , 0);

  return (
    <div style={{
      position: 'absolute', inset: 0, display: 'flex', alignItems: 'flex-end',
      background: 'rgba(0,0,0,0.35)', zIndex: 10,
      animation: 'mmFade 220ms ease-out',
    }} onClick={onCancel}>
      <div onClick={e => e.stopPropagation()} style={{
        width: '100%',
        borderTopLeftRadius: 24, borderTopRightRadius: 24,
        background: t.color.surfaceElevated,
        padding: '14px 20px 28px',
        animation: 'mmSlideUp 320ms cubic-bezier(0.34, 1.2, 0.64, 1)',
        maxHeight: '80%', overflow: 'auto',
      }}>
        {/* Grabber */}
        <div style={{ width: 36, height: 5, borderRadius: 3, background: t.color.border,
          margin: '0 auto 10px' }}/>

        <div style={{ textAlign: 'center' }}>
          <div style={{ ...typeStyle(t.type.caption2, t.family), color: t.color.textTertiary,
            textTransform: 'uppercase', letterSpacing: 0.9 }}>
            Finish session
          </div>
          <div style={{ fontFamily: t.family.serif || t.family.rounded, fontSize: 26, lineHeight: 1.25,
            color: t.color.textPrimary, marginTop: 8,
            fontStyle: t.family.serif ? 'italic' : 'normal', letterSpacing: -0.3 }}>
            You showed up.<br/>That's the whole thing.
          </div>
        </div>

        {/* Summary tiles */}
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 8, marginTop: 18 }}>
          <FinishStat t={t} label="Time" value={formatMS(elapsed)} mono/>
          <FinishStat t={t} label="Sets"  value={`${doneSets} / ${totalSets}`}/>
          <FinishStat t={t} label="Volume" value={totalVolume.toLocaleString()} unit="lb"/>
        </div>

        {/* Mood question */}
        <div style={{
          marginTop: 18, padding: '14px 16px', borderRadius: t.radius.card,
          background: t.color.primaryTint,
        }}>
          <div style={{ ...typeStyle(t.type.callout, t.family), color: t.color.textPrimary,
            fontWeight: 600 }}>
            How did that feel?
          </div>
          <div style={{ display: 'flex', gap: 6, marginTop: 10 }}>
            {['Tough', 'Steady', 'Strong', 'Easy'].map((m, i) => (
              <button key={m} style={{
                flex: 1, padding: '10px 8px', borderRadius: 12, border: 'none',
                background: i === 2 ? t.color.primary : t.color.surfaceCard,
                color: i === 2 ? t.color.onPrimary : t.color.textPrimary,
                fontFamily: t.family.rounded, fontSize: 13, fontWeight: 600,
                cursor: 'pointer',
              }}>
                {m}
              </button>
            ))}
          </div>
        </div>

        {/* Buttons */}
        <div style={{ display: 'flex', gap: 10, marginTop: 18 }}>
          <button onClick={onCancel} style={{
            flex: 1, padding: '14px', borderRadius: t.radius.pill, border: 'none',
            background: t.color.surfaceCard, cursor: 'pointer',
            fontFamily: t.family.rounded, fontSize: 16, fontWeight: 600,
            color: t.color.textPrimary,
          }}>
            Keep going
          </button>
          <button onClick={onFinish} style={{
            flex: 2, padding: '14px', borderRadius: t.radius.pill, border: 'none',
            background: t.color.primary, cursor: 'pointer',
            fontFamily: t.family.rounded, fontSize: 16, fontWeight: 700,
            color: t.color.onPrimary,
          }}>
            Save & finish
          </button>
        </div>
      </div>
    </div>
  );
}

function FinishStat({ t, label, value, unit, mono }) {
  return (
    <div style={{
      padding: '14px 10px', borderRadius: t.radius.card,
      background: t.color.surfaceCard, textAlign: 'center',
    }}>
      <div style={{
        fontFamily: mono ? t.family.mono : t.family.rounded,
        fontSize: 22, fontWeight: 700, color: t.color.textPrimary,
        letterSpacing: mono ? 0.2 : -0.4, lineHeight: 1,
      }}>
        {value}
        {unit && <span style={{ fontSize: 12, fontWeight: 500, color: t.color.textSecondary, marginLeft: 2 }}>{unit}</span>}
      </div>
      <div style={{ ...typeStyle(t.type.caption2, t.family), color: t.color.textTertiary,
        textTransform: 'uppercase', letterSpacing: 0.6, marginTop: 6 }}>
        {label}
      </div>
    </div>
  );
}

Object.assign(window, { LoggerScreen });
