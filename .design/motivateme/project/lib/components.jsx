// components.jsx — Core MotivateMe components
// Needs window.Icon, window.MMTokens, window.typeStyle

// ── Progress Ring ─────────────────────────────────────────
function ProgressRing({ progress = 0.5, size = 56, stroke = 5, color, trackColor, children }) {
  const r = (size - stroke) / 2;
  const c = 2 * Math.PI * r;
  const offset = c * (1 - Math.min(1, Math.max(0, progress)));
  return (
    <div style={{ position: 'relative', width: size, height: size, display: 'inline-flex', alignItems: 'center', justifyContent: 'center' }}>
      <svg width={size} height={size} style={{ transform: 'rotate(-90deg)' }}>
        <circle cx={size/2} cy={size/2} r={r} fill="none" stroke={trackColor} strokeWidth={stroke}/>
        <circle cx={size/2} cy={size/2} r={r} fill="none" stroke={color} strokeWidth={stroke}
          strokeDasharray={c} strokeDashoffset={offset} strokeLinecap="round"
          style={{ transition: 'stroke-dashoffset 600ms cubic-bezier(0.34, 1.2, 0.64, 1)' }}/>
      </svg>
      <div style={{ position: 'absolute', inset: 0, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        {children}
      </div>
    </div>
  );
}

// ── Button ────────────────────────────────────────────────
function MMButton({ t, variant = 'primary', size = 'lg', children, onClick, icon, full = true, style = {} }) {
  const h = size === 'lg' ? 52 : size === 'md' ? 40 : 32;
  const fs = size === 'lg' ? 17 : size === 'md' ? 15 : 13;
  const padX = size === 'lg' ? 20 : size === 'md' ? 16 : 12;

  const variants = {
    primary:    { bg: t.color.primary, fg: t.color.onPrimary, shadow: t.elev.sm },
    secondary:  { bg: t.color.primaryMuted, fg: t.color.primary, shadow: 'none' },
    tertiary:   { bg: 'transparent', fg: t.color.primary, shadow: 'none' },
    destructive:{ bg: t.color.error, fg: '#FFFFFF', shadow: t.elev.sm },
    ghost:      { bg: t.color.surfaceInput, fg: t.color.textPrimary, shadow: 'none' },
  };
  const v = variants[variant];
  return (
    <button onClick={onClick} style={{
      display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 8,
      height: h, padding: `0 ${padX}px`, width: full ? '100%' : undefined,
      borderRadius: 9999, border: 'none', background: v.bg, color: v.fg,
      fontFamily: t.family.rounded, fontSize: fs, fontWeight: 600,
      letterSpacing: -0.2, cursor: 'pointer', boxShadow: v.shadow,
      transition: 'transform 180ms cubic-bezier(0.34, 1.2, 0.64, 1), filter 180ms',
      ...style,
    }}
    onMouseDown={(e) => e.currentTarget.style.transform = 'scale(0.97)'}
    onMouseUp={(e) => e.currentTarget.style.transform = 'scale(1)'}
    onMouseLeave={(e) => e.currentTarget.style.transform = 'scale(1)'}
    >
      {icon && <Icon name={icon} size={size === 'lg' ? 18 : 16} color={v.fg}/>}
      {children}
    </button>
  );
}

// ── Habit / Workout Card ──────────────────────────────────
function HabitCard({ t, title, subtitle, progress, streak, checked, onToggle, category = 'Strength', duration }) {
  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 14, padding: 14,
      background: t.color.surfaceCard, borderRadius: t.radius.card,
      boxShadow: t.elev.sm,
    }}>
      <ProgressRing
        progress={checked ? 1 : progress}
        size={52} stroke={4}
        color={checked ? t.color.secondary : t.color.primary}
        trackColor={t.color.primaryMuted}>
        <button onClick={onToggle} style={{
          width: 38, height: 38, borderRadius: 9999, border: 'none',
          background: checked ? t.color.secondary : 'transparent',
          display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer',
          transition: 'background 260ms cubic-bezier(0.34, 1.2, 0.64, 1)',
        }}>
          {checked && <Icon name="check" size={20} color="#fff" strokeWidth={2.5}/>}
        </button>
      </ProgressRing>

      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 2 }}>
          <span style={{ ...typeStyle(t.type.caption2, t.family), color: t.color.textTertiary, textTransform: 'uppercase' }}>
            {category}
          </span>
          {duration && (
            <>
              <span style={{ color: t.color.textTertiary, fontSize: 10 }}>·</span>
              <span style={{ ...typeStyle(t.type.caption2, t.family), color: t.color.textTertiary }}>{duration}</span>
            </>
          )}
        </div>
        <div style={{ ...typeStyle(t.type.headline, t.family), color: t.color.textPrimary, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
          {title}
        </div>
        {subtitle && (
          <div style={{ ...typeStyle(t.type.footnote, t.family), color: t.color.textSecondary, marginTop: 1 }}>
            {subtitle}
          </div>
        )}
      </div>

      {streak > 0 && (
        <div style={{ display: 'flex', alignItems: 'center', gap: 3,
          padding: '4px 9px', borderRadius: 9999,
          background: checked ? t.color.secondaryMuted : t.color.primaryMuted,
        }}>
          <Icon name="flame" size={12} color={checked ? t.color.secondary : t.color.primary} filled/>
          <span style={{ fontFamily: t.family.rounded, fontSize: 12, fontWeight: 700, color: checked ? t.color.secondary : t.color.primary }}>
            {streak}
          </span>
        </div>
      )}
    </div>
  );
}

// ── Streak Hero ───────────────────────────────────────────
function StreakHero({ t, days, message }) {
  return (
    <div style={{
      padding: '26px 22px 24px', borderRadius: t.radius.cardLg,
      background: `linear-gradient(160deg, ${t.color.primaryTint}, ${t.color.surfaceCard} 75%)`,
      boxShadow: t.elev.sm, position: 'relative', overflow: 'hidden',
    }}>
      {/* Sun arc motif, top-right */}
      <div style={{ position: 'absolute', top: -40, right: -40, width: 150, height: 150, borderRadius: '50%',
        background: `radial-gradient(circle at center, ${t.color.primary}22, transparent 70%)` }}/>
      <div style={{ display: 'flex', alignItems: 'baseline', gap: 10 }}>
        <span style={{ fontFamily: t.family.rounded, fontSize: 72, fontWeight: 700, lineHeight: '76px', letterSpacing: -2, color: t.color.primary }}>
          {days}
        </span>
        <span style={{ ...typeStyle(t.type.title3, t.family), color: t.color.textSecondary }}>
          day{days === 1 ? '' : 's'}
        </span>
      </div>
      <div style={{ ...typeStyle(t.type.headline, t.family), color: t.color.textPrimary, marginTop: 4 }}>
        {message}
      </div>
    </div>
  );
}

// ── Calendar Heatmap ──────────────────────────────────────
function Heatmap({ t, data, weeks = 12 }) {
  // data: array of length weeks*7, values 0..1
  const cell = 14, gap = 4;
  return (
    <div>
      <div style={{ display: 'grid', gridTemplateColumns: `repeat(${weeks}, ${cell}px)`, gap, justifyContent: 'center' }}>
        {Array.from({ length: weeks * 7 }).map((_, i) => {
          const v = data[i] ?? 0;
          const bg = v === 0
            ? (t.color.separator)
            : v < 0.34 ? t.color.primaryScale[200]
            : v < 0.67 ? t.color.primaryScale[400]
            : t.color.primaryScale[500];
          return <div key={i} style={{ width: cell, height: cell, borderRadius: 4, background: bg }}/>;
        })}
      </div>
      <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: 10,
        ...typeStyle(t.type.caption2, t.family), color: t.color.textTertiary }}>
        <span>12 weeks ago</span><span>Today</span>
      </div>
    </div>
  );
}

// ── Daily Check-in Card ───────────────────────────────────
const MOODS = [
  { k: 'great', label: 'Great',   emoji: '🌤' },
  { k: 'good',  label: 'Good',    emoji: '🌿' },
  { k: 'okay',  label: 'Okay',    emoji: '🍵' },
  { k: 'tired', label: 'Tired',   emoji: '🌙' },
  { k: 'rough', label: 'Rough',   emoji: '☁️' },
];

function CheckinCard({ t, mood, onMood, readiness, onReadiness, prompt, journal, onJournal, compact = false }) {
  return (
    <div style={{
      padding: 20, borderRadius: t.radius.cardLg, background: t.color.surfaceCard,
      boxShadow: t.elev.md,
    }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 14 }}>
        <Icon name="sun" size={18} color={t.color.primary}/>
        <span style={{ ...typeStyle(t.type.headline, t.family), color: t.color.textPrimary }}>
          Morning check-in
        </span>
      </div>

      <div style={{ ...typeStyle(t.type.subhead, t.family), color: t.color.textSecondary, marginBottom: 10 }}>
        How's the body today?
      </div>

      <div style={{ display: 'flex', gap: 8, marginBottom: 18 }}>
        {MOODS.map(m => {
          const sel = mood === m.k;
          return (
            <button key={m.k} onClick={() => onMood?.(m.k)} style={{
              flex: 1, padding: '10px 4px', borderRadius: 14, border: 'none',
              background: sel ? t.color.primaryMuted : t.color.surfaceInput,
              outline: sel ? `1.5px solid ${t.color.primary}` : 'none',
              outlineOffset: -1.5,
              display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4,
              cursor: 'pointer', transition: 'all 260ms cubic-bezier(0.34, 1.2, 0.64, 1)',
              transform: sel ? 'translateY(-2px)' : 'translateY(0)',
            }}>
              <span style={{ fontSize: 22 }}>{m.emoji}</span>
              <span style={{ fontFamily: t.family.rounded, fontSize: 11, fontWeight: 600,
                color: sel ? t.color.primary : t.color.textSecondary }}>{m.label}</span>
            </button>
          );
        })}
      </div>

      {!compact && (
        <>
          <div style={{ ...typeStyle(t.type.subhead, t.family), color: t.color.textSecondary, marginBottom: 8 }}>
            Readiness <span style={{ color: t.color.textTertiary }}>· {readiness}/10</span>
          </div>
          <ReadinessSlider t={t} value={readiness} onChange={onReadiness}/>

          <div style={{ ...typeStyle(t.type.subhead, t.family), color: t.color.textSecondary, margin: '18px 0 8px' }}>
            {prompt}
          </div>
          <textarea value={journal} onChange={e => onJournal?.(e.target.value)} placeholder="A few words…"
            style={{
              width: '100%', minHeight: 72, resize: 'none', padding: 12,
              border: 'none', outline: 'none',
              background: t.color.surfaceInput, borderRadius: 14,
              fontFamily: t.family.text, fontSize: 15, lineHeight: '21px',
              color: t.color.textPrimary, boxSizing: 'border-box',
            }}/>
        </>
      )}
    </div>
  );
}

// ── Readiness Slider ──────────────────────────────────────
function ReadinessSlider({ t, value = 7, onChange }) {
  return (
    <div style={{ padding: '6px 4px' }}>
      <div style={{ display: 'flex', gap: 4 }}>
        {Array.from({ length: 10 }).map((_, i) => {
          const active = i < value;
          const n = i + 1;
          return (
            <button key={i} onClick={() => onChange?.(n)} style={{
              flex: 1, height: 28, borderRadius: 8, border: 'none', cursor: 'pointer',
              background: active
                ? `oklch(${0.95 - (n/10)*0.25} ${0.02 + (n/10)*0.11} ${45 + (n-1)*3})`
                : t.color.surfaceInput,
              transition: 'background 180ms',
            }}/>
          );
        })}
      </div>
      <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: 6,
        ...typeStyle(t.type.caption2, t.family), color: t.color.textTertiary }}>
        <span>Wiped</span><span>Ready</span>
      </div>
    </div>
  );
}

// ── Notification: in-app banner ───────────────────────────
function InAppBanner({ t, title, body, icon = 'sparkles' }) {
  return (
    <div style={{
      margin: '0 12px', padding: '12px 14px', borderRadius: 18,
      background: t.color.surfaceElevated, boxShadow: t.elev.lg,
      display: 'flex', alignItems: 'center', gap: 12,
      backdropFilter: 'blur(20px) saturate(180%)',
    }}>
      <div style={{ width: 36, height: 36, borderRadius: 10, background: t.color.primaryMuted,
        display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
        <Icon name={icon} size={20} color={t.color.primary}/>
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ ...typeStyle(t.type.footnote, t.family), fontWeight: 600, color: t.color.textPrimary }}>{title}</div>
        <div style={{ ...typeStyle(t.type.caption1, t.family), color: t.color.textSecondary }}>{body}</div>
      </div>
    </div>
  );
}

// ── Notification: lock screen preview ─────────────────────
function LockScreenNotif({ t, title, body, app = 'MotivateMe', time = 'now' }) {
  return (
    <div style={{
      padding: '12px 14px', borderRadius: 18,
      background: 'rgba(30,22,16,0.55)',
      backdropFilter: 'blur(24px) saturate(180%)',
      WebkitBackdropFilter: 'blur(24px) saturate(180%)',
      border: '0.5px solid rgba(255,255,255,0.12)',
    }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 6 }}>
        <div style={{ width: 20, height: 20, borderRadius: 5, background: t.color.primary,
          display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <Icon name="sun" size={12} color="#fff" strokeWidth={2.4}/>
        </div>
        <span style={{ fontFamily: t.family.text, fontSize: 13, fontWeight: 500, color: 'rgba(255,255,255,0.9)' }}>{app}</span>
        <span style={{ flex: 1 }}/>
        <span style={{ fontFamily: t.family.text, fontSize: 13, color: 'rgba(255,255,255,0.55)' }}>{time}</span>
      </div>
      <div style={{ fontFamily: t.family.rounded, fontSize: 15, fontWeight: 600, color: '#fff', marginBottom: 2 }}>{title}</div>
      <div style={{ fontFamily: t.family.text, fontSize: 14, color: 'rgba(255,255,255,0.82)', lineHeight: '18px' }}>{body}</div>
    </div>
  );
}

// ── Live Activity (Dynamic Island / banner) ───────────────
function LiveActivity({ t, variant = 'banner', streak = 12, minutesLeft = 18 }) {
  if (variant === 'island') {
    return (
      <div style={{
        width: 380, height: 37, borderRadius: 24, background: '#000',
        display: 'flex', alignItems: 'center', padding: '0 14px', gap: 10,
      }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
          <Icon name="flame" size={14} color={t.color.primary} filled/>
          <span style={{ fontFamily: t.family.rounded, fontSize: 13, fontWeight: 700, color: '#fff' }}>{streak}</span>
        </div>
        <div style={{ flex: 1 }}/>
        <span style={{ fontFamily: t.family.mono, fontSize: 13, color: t.color.primary, fontWeight: 600 }}>
          {minutesLeft}m left today
        </span>
      </div>
    );
  }
  return (
    <div style={{
      padding: 14, borderRadius: 22, background: '#1a1410',
      display: 'flex', alignItems: 'center', gap: 12,
      border: '0.5px solid rgba(255,255,255,0.08)',
    }}>
      <div style={{ width: 44, height: 44, borderRadius: 12, background: t.color.primaryMuted,
        display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <Icon name="flame" size={22} color={t.color.primary} filled/>
      </div>
      <div style={{ flex: 1 }}>
        <div style={{ fontFamily: t.family.rounded, fontSize: 11, fontWeight: 600, color: 'rgba(255,255,255,0.55)', textTransform: 'uppercase', letterSpacing: 0.5 }}>
          Streak · {streak} days
        </div>
        <div style={{ fontFamily: t.family.rounded, fontSize: 16, fontWeight: 600, color: '#fff', marginTop: 2 }}>
          {minutesLeft} minutes left to keep it
        </div>
      </div>
      <button style={{ padding: '8px 14px', borderRadius: 9999, border: 'none',
        background: t.color.primary, color: '#fff', fontFamily: t.family.rounded, fontWeight: 600, fontSize: 13,
        cursor: 'pointer' }}>Open</button>
    </div>
  );
}

Object.assign(window, {
  ProgressRing, MMButton, HabitCard, StreakHero, Heatmap, CheckinCard,
  ReadinessSlider, InAppBanner, LockScreenNotif, LiveActivity, MOODS,
});
