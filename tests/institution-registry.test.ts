import { describe, it, expect, beforeEach, vi } from 'vitest'

describe('Institution Registry Contract', () => {
  let mockContractCall: any
  
  beforeEach(() => {
    mockContractCall = vi.fn()
  })
  
  it('should register an institution', async () => {
    mockContractCall.mockResolvedValue({ success: true })
    const result = await mockContractCall('register-institution', 'University of Blockchain', 'https://www.uniblockchain.edu')
    expect(result.success).toBe(true)
  })
  
  it('should verify an institution', async () => {
    mockContractCall.mockResolvedValue({ success: true })
    const result = await mockContractCall('verify-institution', 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM')
    expect(result.success).toBe(true)
  })
  
  it('should get institution details', async () => {
    mockContractCall.mockResolvedValue({
      success: true,
      value: {
        name: 'University of Blockchain',
        website: 'https://www.uniblockchain.edu',
        verified: true
      }
    })
    const result = await mockContractCall('get-institution', 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM')
    expect(result.success).toBe(true)
    expect(result.value.name).toBe('University of Blockchain')
    expect(result.value.verified).toBe(true)
  })
  
  it('should check if an institution is verified', async () => {
    mockContractCall.mockResolvedValue({ success: true, value: true })
    const result = await mockContractCall('is-verified-institution', 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM')
    expect(result.success).toBe(true)
    expect(result.value).toBe(true)
  })
})
