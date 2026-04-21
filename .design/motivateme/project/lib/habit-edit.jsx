// habit-edit.jsx — Bottom sheet for creating, editing, and archiving habits.
// Opens in two modes: 'new' (blank) and 'edit' (prefilled). Emits onSave / onArchive / onDelete.

const HABIT_CATEGORIES = [
  { id: 'Strength', icon: 'dumbbell', color: '#D97757' },
  { id: 'Movement', icon: 'figure',   color: '#8BA76B' },
  { id: 'Mobility', icon: 'leaf',     color: '#7AA5B8' },
  { id: 'Reflect',  icon: 'book',     color: '#A08BB5' },
  { id: 'Care',     icon: 'heart',    color: '#E56B8E' },
  { id: 'Rest',     icon: 'moon',     color: '#6F6BB5' },
];

const FREQUENCY_PRESETS = [
  { id: 'daily',    label: 'Every day',    target: 7 },
  { id: 'weekdays', label: 'Weekdays',     target: 5 },
  { id: 'most',     label: 'Most days',    target: 5 },
  { id: 'some',     label: 'A few times',  target: 3 },
  { id: 'weekly',   label: 'Once a week',  target: 1 },
];

const DAY_LABELS = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

function HabitEditSheet({ t, habit, mode = 'new', onSave, onArchive, onDelete, onCancel }) {
  // Mode: 'new' | 'edit'
  const [title, setTitle] = React.useState(habit?.title || '');
  const [subtitle, setSubtitle] = React.useState(habit?.subtitle || '');
  const [category, setCategory] = React.useState(habit?.category || 'Movement');
  const [duration, setDuration] = React.useState(habit?.durationMin || 20);
  const [frequency, setFrequency] = React.useState(habit?.frequency || 'most');
  const [customDays, setCustomDays] = React.useState(habit?.customDays || [1,2,3,4,5]); // 0=Sun..6=Sat
  const [timeOfDay, setTimeOfDay] = React.useState(habit?.timeOfDay || 'flexible');
  const [reminder, setReminder] = React.useState(habit?.reminder ?? true);
  const [reminderTime, setReminderTime] = React.useState(habit?.reminderTime || '08:00');
  const [confirmDelete, setConfirmDelete] = React.useState(false);

  const cat = HABIT_CATEGORIES.find(c => c.id === category) || HABIT_CATEGORIES[1];

  const canSave = title.trim().length > 0;

  const handleSave = () => {
    if (!canSave) return;
    const updated = {
      ...(habit || {}),
      id: habit?.id || `h${Date.now()}`,
      title: title.trim(),
      subtitle: subtitle.trim() || `${duration} min · ${cat.id.toLowerCase()}`,
      category: cat.id,
      icon: cat.icon,
      durationMin: duration,
      duration: `${duration} min`,
      frequency,
      customDays: frequency === 'custom' ? customDays : undefined,
      timeOfDay,
      reminder,
      reminderTime,
      // New habit defaults
      progress: habit?.progress ?? 0,
      streak: habit?.streak ?? 0,
      checked: habit?.checked ?? false,
      lastDone: habit?.lastDone || 'not yet',
      weekDone: habit?.weekDone ?? 0,
      weekTarget: habit?.weekTarget ?? (FREQUENCY_PRESETS.find(f => f.id === frequency)?.target || 5),
      allTime: habit?.allTime ?? 0,
    };
    onSave(updated, mode);
  };

  return (
    <div onClick={onCancel}
      style={{
        position: 'absolute', inset: 0, zIndex: 50,
        background: 'rgba(20, 15, 10, 0.45)',
        display: 'flex', alignItems: 'flex-end',
        animation: 'mmFade 220ms ease-out',
      }}>
      <div onClick={e => e.stopPropagation()}
        style={{
          width: '100%', maxHeight: '92%',
          background: t.color.bg,
          borderTopLeftRadius: 22, borderTopRightRadius: 22,
          overflow: 'hidden',
          display: 'flex', flexDirection: 'column',
          animation: 'mmSlideUp 320ms cubic-bezier(0.34, 1.2, 0.64, 1)',
        }}>
        {/* Grabber + title bar */}
        <div style={{ padding: '10px 16px 4px', textAlign: 'center' }}>
          <div style={{ width: 40, height: 4, borderRadius: 2, margin: '0 auto 10px',
            background: t.color.border }}/>
        </div>
        <div style={{ padding: '0 16px 10px',
          display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <button onClick={onCancel}
            style={{ border: 'none', background: 'transparent', cursor: 'pointer',
              fontFamily: t.family.text, fontSize: 16, color: t.color.primary, padding: 4 }}>
            Cancel
          </button>
          <div style={{ ...typeStyle(t.type.headline, t.family),
            color: t.color.textPrimary }}>
            {mode === 'new' ? 'New habit' : 'Edit habit'}
          </div>
          <button onClick={handleSave} disabled={!canSave}
            style={{ border: 'none', background: 'transparent',
              cursor: canSave ? 'pointer' : 'default',
              fontFamily: t.family.rounded, fontSize: 16, fontWeight: 700,
              color: canSave ? t.color.primary : t.color.textTertiary,
              padding: 4 }}>
            {mode === 'new' ? 'Add' : 'Save'}
          </button>
        </div>

        {/* Scrollable content */}
        <div style={{ flex: 1, overflow: 'auto', padding: '4px 16px 24px' }}>

          {/* Preview card */}
          <div style={{
            marginTop: 6, marginBottom: 18,
            padding: '14px 14px', borderRadius: t.radius.card,
            background: t.color.surfaceCard, boxShadow: t.elev.sm,
            display: 'flex', alignItems: 'center', gap: 12,
          }}>
            <div style={{
              width: 44, height: 44, borderRadius: 12,
              background: cat.color,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              transition: 'background 220ms',
            }}>
              <Icon name={cat.icon} size={20} color="#fff"/>
            </div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ ...typeStyle(t.type.headline, t.family),
                color: title ? t.color.textPrimary : t.color.textTertiary,
                fontStyle: title ? 'normal' : 'italic' }}>
                {title || 'Your habit'}
              </div>
              <div style={{ ...typeStyle(t.type.footnote, t.family),
                color: t.color.textSecondary, marginTop: 1 }}>
                {cat.id} · {duration} min · {(FREQUENCY_PRESETS.find(f=>f.id===frequency) || {label:'Custom'}).label.toLowerCase()}
              </div>
            </div>
          </div>

          {/* Title input */}
          <Field t={t} label="Name this habit">
            <input autoFocus
              value={title} onChange={e => setTitle(e.target.value)}
              placeholder="e.g. Morning walk"
              style={inputStyle(t)}/>
          </Field>

          {/* Subtitle input */}
          <Field t={t} label="A short note" sub="Optional — for you, not us">
            <input
              value={subtitle} onChange={e => setSubtitle(e.target.value)}
              placeholder="Keep it simple. One line."
              style={inputStyle(t)}/>
          </Field>

          {/* Category */}
          <Field t={t} label="Category">
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 8 }}>
              {HABIT_CATEGORIES.map(c => {
                const selected = category === c.id;
                return (
                  <button key={c.id} onClick={() => setCategory(c.id)}
                    style={{
                      padding: '12px 8px', borderRadius: 14, cursor: 'pointer',
                      background: selected ? `color-mix(in oklab, ${c.color} 18%, ${t.color.surfaceCard})` : t.color.surfaceCard,
                      border: selected ? `1.5px solid ${c.color}` : `1.5px solid transparent`,
                      boxShadow: t.elev.xs,
                      display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6,
                      transition: 'all 180ms cubic-bezier(0.34, 1.2, 0.64, 1)',
                    }}>
                    <div style={{
                      width: 30, height: 30, borderRadius: 8,
                      background: c.color,
                      display: 'flex', alignItems: 'center', justifyContent: 'center',
                    }}>
                      <Icon name={c.icon} size={16} color="#fff"/>
                    </div>
                    <div style={{ ...typeStyle(t.type.caption1, t.family),
                      color: t.color.textPrimary, fontWeight: selected ? 600 : 500 }}>
                      {c.id}
                    </div>
                  </button>
                );
              })}
            </div>
          </Field>

          {/* Duration */}
          <Field t={t} label="How long" sub={`${duration} minutes — you can always adjust`}>
            <div style={{
              padding: '14px 16px 10px', borderRadius: 14,
              background: t.color.surfaceCard, boxShadow: t.elev.xs,
            }}>
              <input type="range" min="2" max="90" step="1"
                value={duration} onChange={e => setDuration(+e.target.value)}
                style={{ width: '100%', accentColor: cat.color }}/>
              <div style={{ display: 'flex', justifyContent: 'space-between',
                ...typeStyle(t.type.caption2, t.family), color: t.color.textTertiary, marginTop: 4 }}>
                <span>2 min</span><span>30 min</span><span>90 min</span>
              </div>
            </div>
          </Field>

          {/* Frequency */}
          <Field t={t} label="How often">
            <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
              {FREQUENCY_PRESETS.map(f => {
                const selected = frequency === f.id;
                return (
                  <button key={f.id} onClick={() => setFrequency(f.id)}
                    style={{
                      padding: '12px 14px', borderRadius: 12, cursor: 'pointer',
                      background: selected ? t.color.primaryTint : t.color.surfaceCard,
                      border: selected ? `1.5px solid ${t.color.primary}` : `1.5px solid transparent`,
                      boxShadow: t.elev.xs,
                      display: 'flex', alignItems: 'center', justifyContent: 'space-between',
                      textAlign: 'left',
                      transition: 'all 160ms',
                    }}>
                    <span style={{ ...typeStyle(t.type.callout, t.family),
                      color: t.color.textPrimary, fontWeight: selected ? 600 : 500 }}>
                      {f.label}
                    </span>
                    <span style={{ ...typeStyle(t.type.caption1, t.family),
                      color: t.color.textTertiary }}>
                      {f.target}×/week
                    </span>
                  </button>
                );
              })}
              <button onClick={() => setFrequency('custom')}
                style={{
                  padding: '12px 14px', borderRadius: 12, cursor: 'pointer',
                  background: frequency === 'custom' ? t.color.primaryTint : t.color.surfaceCard,
                  border: frequency === 'custom' ? `1.5px solid ${t.color.primary}` : `1.5px solid transparent`,
                  boxShadow: t.elev.xs,
                  display: 'flex', alignItems: 'center', justifyContent: 'space-between',
                  textAlign: 'left',
                }}>
                <span style={{ ...typeStyle(t.type.callout, t.family),
                  color: t.color.textPrimary, fontWeight: frequency === 'custom' ? 600 : 500 }}>
                  Specific days
                </span>
                <span style={{ ...typeStyle(t.type.caption1, t.family),
                  color: t.color.textTertiary }}>
                  {frequency === 'custom' ? `${customDays.length}/week` : 'pick days'}
                </span>
              </button>
              {frequency === 'custom' && (
                <div style={{
                  display: 'flex', gap: 6, padding: '10px 4px 2px',
                  justifyContent: 'space-between',
                }}>
                  {DAY_LABELS.map((d, i) => {
                    const active = customDays.includes(i);
                    return (
                      <button key={i} onClick={() => {
                        setCustomDays(active ? customDays.filter(x => x !== i) : [...customDays, i].sort());
                      }}
                        style={{
                          flex: 1, aspectRatio: '1',
                          borderRadius: '50%', border: 'none', cursor: 'pointer',
                          background: active ? t.color.primary : t.color.surfaceCard,
                          color: active ? t.color.onPrimary : t.color.textSecondary,
                          fontFamily: t.family.rounded, fontSize: 14, fontWeight: 600,
                          boxShadow: t.elev.xs,
                          transition: 'all 160ms cubic-bezier(0.34, 1.2, 0.64, 1)',
                        }}>
                        {d}
                      </button>
                    );
                  })}
                </div>
              )}
            </div>
          </Field>

          {/* Time of day */}
          <Field t={t} label="Time of day">
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr 1fr', gap: 6 }}>
              {[
                {id:'morning',   icon:'sun',   label:'Morning'},
                {id:'afternoon', icon:'sun',   label:'Afternoon'},
                {id:'evening',   icon:'moon',  label:'Evening'},
                {id:'flexible',  icon:'dot',   label:'Anytime'},
              ].map(opt => {
                const selected = timeOfDay === opt.id;
                return (
                  <button key={opt.id} onClick={() => setTimeOfDay(opt.id)}
                    style={{
                      padding: '10px 4px', borderRadius: 12, cursor: 'pointer',
                      background: selected ? t.color.primaryTint : t.color.surfaceCard,
                      border: selected ? `1.5px solid ${t.color.primary}` : `1.5px solid transparent`,
                      boxShadow: t.elev.xs,
                      display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4,
                      transition: 'all 160ms',
                    }}>
                    <Icon name={opt.icon} size={16} color={selected ? t.color.primary : t.color.textSecondary}/>
                    <span style={{ ...typeStyle(t.type.caption1, t.family),
                      color: t.color.textPrimary, fontWeight: selected ? 600 : 500 }}>
                      {opt.label}
                    </span>
                  </button>
                );
              })}
            </div>
          </Field>

          {/* Reminder toggle */}
          <Field t={t} label="Nudge me">
            <div style={{
              padding: '12px 14px', borderRadius: 14,
              background: t.color.surfaceCard, boxShadow: t.elev.xs,
              display: 'flex', alignItems: 'center', gap: 12,
            }}>
              <div style={{
                width: 34, height: 34, borderRadius: 10,
                background: reminder ? cat.color : t.color.border,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                transition: 'background 220ms',
              }}>
                <Icon name="bell" size={16} color={reminder ? '#fff' : t.color.textTertiary}/>
              </div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ ...typeStyle(t.type.callout, t.family),
                  color: t.color.textPrimary, fontWeight: 500 }}>
                  {reminder ? `At ${formatTime(reminderTime)}` : 'No reminder'}
                </div>
                <div style={{ ...typeStyle(t.type.caption1, t.family),
                  color: t.color.textTertiary, marginTop: 1 }}>
                  {reminder ? 'One gentle notification' : 'You\u2019ll come back when you\u2019re ready'}
                </div>
              </div>
              {reminder && (
                <input type="time" value={reminderTime} onChange={e => setReminderTime(e.target.value)}
                  style={{
                    fontFamily: t.family.rounded, fontSize: 14,
                    padding: '4px 8px', borderRadius: 8,
                    border: `1px solid ${t.color.border}`,
                    background: t.color.bg, color: t.color.textPrimary,
                  }}/>
              )}
              <MiniSwitch t={t} value={reminder} onChange={setReminder}/>
            </div>
          </Field>

          {/* Edit-mode-only actions */}
          {mode === 'edit' && (
            <div style={{
              marginTop: 28, padding: '14px', borderRadius: 14,
              background: t.color.surfaceCard, boxShadow: t.elev.xs,
            }}>
              <div style={{
                ...typeStyle(t.type.footnote, t.family),
                color: t.color.textTertiary,
                textTransform: 'uppercase', letterSpacing: 0.8,
                marginBottom: 8,
              }}>
                If this isn\u2019t working
              </div>

              <button onClick={onArchive}
                style={{
                  width: '100%', padding: '12px', borderRadius: 10, cursor: 'pointer',
                  border: 'none', background: 'transparent', textAlign: 'left',
                  display: 'flex', alignItems: 'center', gap: 10,
                }}>
                <Icon name="moon" size={18} color={t.color.textSecondary}/>
                <div style={{ flex: 1 }}>
                  <div style={{ ...typeStyle(t.type.callout, t.family),
                    color: t.color.textPrimary, fontWeight: 500 }}>
                    Pause this habit
                  </div>
                  <div style={{ ...typeStyle(t.type.caption1, t.family),
                    color: t.color.textTertiary, marginTop: 1 }}>
                    Your streak stays frozen. Come back whenever.
                  </div>
                </div>
              </button>

              {!confirmDelete ? (
                <button onClick={() => setConfirmDelete(true)}
                  style={{
                    width: '100%', padding: '12px', borderRadius: 10, cursor: 'pointer',
                    border: 'none', background: 'transparent', textAlign: 'left',
                    display: 'flex', alignItems: 'center', gap: 10,
                    borderTop: `0.5px solid ${t.color.border}`, marginTop: 4,
                  }}>
                  <Icon name="trash" size={18} color="#C45A5A"/>
                  <div style={{ flex: 1 }}>
                    <div style={{ ...typeStyle(t.type.callout, t.family),
                      color: '#C45A5A', fontWeight: 500 }}>
                      Delete this habit
                    </div>
                    <div style={{ ...typeStyle(t.type.caption1, t.family),
                      color: t.color.textTertiary, marginTop: 1 }}>
                      The history stays in your archive.
                    </div>
                  </div>
                </button>
              ) : (
                <div style={{
                  padding: '12px', borderRadius: 10, marginTop: 4,
                  borderTop: `0.5px solid ${t.color.border}`,
                  background: `color-mix(in oklab, #C45A5A 8%, transparent)`,
                }}>
                  <div style={{ ...typeStyle(t.type.callout, t.family),
                    color: t.color.textPrimary, fontWeight: 600 }}>
                    Delete "{title}"?
                  </div>
                  <div style={{ ...typeStyle(t.type.caption1, t.family),
                    color: t.color.textSecondary, marginTop: 2, lineHeight: 1.4 }}>
                    Past sessions stay in History. Only the ongoing habit is removed.
                  </div>
                  <div style={{ display: 'flex', gap: 8, marginTop: 10 }}>
                    <button onClick={() => setConfirmDelete(false)}
                      style={{
                        flex: 1, padding: '10px', borderRadius: 10, cursor: 'pointer',
                        border: `1px solid ${t.color.border}`, background: 'transparent',
                        color: t.color.textPrimary,
                        fontFamily: t.family.rounded, fontSize: 14, fontWeight: 600,
                      }}>
                      Keep it
                    </button>
                    <button onClick={onDelete}
                      style={{
                        flex: 1, padding: '10px', borderRadius: 10, cursor: 'pointer',
                        border: 'none', background: '#C45A5A', color: '#fff',
                        fontFamily: t.family.rounded, fontSize: 14, fontWeight: 700,
                      }}>
                      Yes, delete
                    </button>
                  </div>
                </div>
              )}
            </div>
          )}

          {/* Ethos nudge on NEW mode */}
          {mode === 'new' && (
            <div style={{
              marginTop: 20, padding: '12px 14px', borderRadius: 12,
              background: t.color.secondaryTint,
              display: 'flex', gap: 10, alignItems: 'flex-start',
            }}>
              <Icon name="leaf" size={14} color={t.color.secondary}/>
              <div style={{ ...typeStyle(t.type.footnote, t.family),
                color: t.color.textPrimary, lineHeight: 1.45 }}>
                Start smaller than feels ambitious. It\u2019s easier to grow a habit than rescue one.
              </div>
            </div>
          )}

          <div style={{ height: 24 }}/>
        </div>
      </div>
    </div>
  );
}

// ── Helpers ───────────────────────────────────────────────

function Field({ t, label, sub, children }) {
  return (
    <div style={{ marginTop: 20 }}>
      <div style={{ padding: '0 4px 8px', display: 'flex', alignItems: 'baseline', gap: 8 }}>
        <div style={{
          ...typeStyle(t.type.footnote, t.family),
          color: t.color.textTertiary,
          textTransform: 'uppercase', letterSpacing: 0.8,
        }}>
          {label}
        </div>
        {sub && (
          <div style={{
            ...typeStyle(t.type.caption2, t.family),
            color: t.color.textTertiary,
            fontStyle: 'italic',
          }}>
            · {sub}
          </div>
        )}
      </div>
      {children}
    </div>
  );
}

function inputStyle(t) {
  return {
    width: '100%',
    padding: '14px 16px', borderRadius: 14,
    border: 'none', outline: 'none',
    background: t.color.surfaceCard, boxShadow: t.elev.xs,
    fontFamily: t.family.rounded, fontSize: 16, fontWeight: 500,
    color: t.color.textPrimary, boxSizing: 'border-box',
  };
}

function MiniSwitch({ t, value, onChange }) {
  return (
    <button onClick={() => onChange(!value)}
      style={{
        width: 44, height: 26, borderRadius: 999, border: 'none', cursor: 'pointer',
        background: value ? '#34C759' : `color-mix(in oklab, ${t.color.textPrimary} 15%, ${t.color.surfaceCard})`,
        position: 'relative', flexShrink: 0, padding: 0,
        transition: 'background 220ms',
      }}>
      <div style={{
        position: 'absolute', top: 2, left: value ? 20 : 2,
        width: 22, height: 22, borderRadius: '50%',
        background: '#fff', boxShadow: '0 2px 6px rgba(0,0,0,0.15)',
        transition: 'left 220ms cubic-bezier(0.34, 1.4, 0.64, 1)',
      }}/>
    </button>
  );
}

function formatTime(hhmm) {
  if (!hhmm) return '—';
  const [h, m] = hhmm.split(':').map(Number);
  const period = h < 12 ? 'AM' : 'PM';
  const hour = h === 0 ? 12 : h > 12 ? h - 12 : h;
  return `${hour}:${String(m).padStart(2, '0')} ${period}`;
}

Object.assign(window, { HabitEditSheet });
