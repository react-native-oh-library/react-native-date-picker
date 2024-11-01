export const formatDateByTime = (hours: number, minutes: number, second: number): string => {
  const time = new Date()
  const y = time.getFullYear()
  const M = addZero(time.getMonth() + 1)
  const d = addZero(time.getDate())
  const h = addZero(hours)
  const m = addZero(minutes)
  const s = addZero(second)
  const date = y + '-' + M + '-' + d + ' ' + h + ':' + m + ':' + s
  return date
}

export const formatDate = (t): string => {
  const time = new Date(t)
  const y = time.getFullYear()
  const M = addZero(time.getMonth() + 1)
  const d = addZero(time.getDate())
  return y + '-' + M + '-' + d
}


export const formatTime = (t): string => {
  const time = new Date(t)
  const h = addZero(time.getHours())
  const m = addZero(time.getMinutes())
  const s = addZero(time.getSeconds())
  return h + ':' + m + ':' + s
}

export const addZero = (e: number): string => {
  if (e < 10) {
    return 0 + '' + e
  }
  return e + ''
}


export const mergeObject = (a: object, b: object) => {
  return Object.assign(a, b)
}