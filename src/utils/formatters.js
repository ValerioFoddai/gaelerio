export const formatAmount = (amount) => {
  const value = amount || 0
  return `${value.toFixed(2)} €`
}