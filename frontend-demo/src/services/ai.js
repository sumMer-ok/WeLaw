// AI API 服务
// Base URL: https://hiapi.online/v1
// API Key: sk-lExN5nEWgcyWYTtuCTcQJDPKWn9LRlD8zj16YsP4FTcgmOih

const BASE_URL = 'https://hiapi.online/v1'
const API_KEY = 'sk-lExN5nEWgcyWYTtuCTcQJDPKWn9LRlD8zj16YsP4FTcgmOih'

/**
 * 发送聊天消息到 AI API
 * @param {Array} messages - 消息列表，格式: [{role: 'user'|'assistant', content: string}]
 * @param {Object} options - 可选参数
 * @returns {Promise<string>} AI 回复内容
 */
export async function sendChatMessage(messages, options = {}) {
  const {
    model = 'gpt-4o-mini',
    temperature = 0.7,
    max_tokens = 2000,
    stream = false
  } = options

  try {
    const response = await fetch(`${BASE_URL}/chat/completions`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${API_KEY}`
      },
      body: JSON.stringify({
        model,
        messages: [
          {
            role: 'system',
            content: '你是EnofLaw AI助手，一个专业的法律学习助手。你帮助用户分析法律案例、解释法律术语、比较相关案例。请用中文回答，回答要专业、准确、易懂。'
          },
          ...messages
        ],
        temperature,
        max_tokens,
        stream
      })
    })

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}))
      throw new Error(errorData.error?.message || `HTTP error! status: ${response.status}`)
    }

    const data = await response.json()
    return data.choices?.[0]?.message?.content || '抱歉，我暂时无法回答您的问题。'
  } catch (error) {
    console.error('AI API 调用失败:', error)
    throw error
  }
}

/**
 * 流式发送聊天消息
 * @param {Array} messages - 消息列表
 * @param {Function} onChunk - 接收到数据块时的回调
 * @param {Object} options - 可选参数
 */
export async function sendChatMessageStream(messages, onChunk, options = {}) {
  const {
    model = 'gpt-4o-mini',
    temperature = 0.7,
    max_tokens = 2000
  } = options

  try {
    const response = await fetch(`${BASE_URL}/chat/completions`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${API_KEY}`
      },
      body: JSON.stringify({
        model,
        messages: [
          {
            role: 'system',
            content: '你是EnofLaw AI助手，一个专业的法律学习助手。你帮助用户分析法律案例、解释法律术语、比较相关案例。请用中文回答，回答要专业、准确、易懂。'
          },
          ...messages
        ],
        temperature,
        max_tokens,
        stream: true
      })
    })

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}))
      throw new Error(errorData.error?.message || `HTTP error! status: ${response.status}`)
    }

    const reader = response.body.getReader()
    const decoder = new TextDecoder()

    while (true) {
      const { done, value } = await reader.read()
      if (done) break

      const chunk = decoder.decode(value, { stream: true })
      const lines = chunk.split('\n').filter(line => line.trim() !== '')

      for (const line of lines) {
        if (line.startsWith('data: ')) {
          const data = line.slice(6)
          if (data === '[DONE]') return

          try {
            const parsed = JSON.parse(data)
            const content = parsed.choices?.[0]?.delta?.content
            if (content) {
              onChunk(content)
            }
          } catch (e) {
            // 忽略解析错误
          }
        }
      }
    }
  } catch (error) {
    console.error('AI API 流式调用失败:', error)
    throw error
  }
}

/**
 * 获取可用模型列表
 * @returns {Promise<Array>} 模型列表
 */
export async function getModels() {
  try {
    const response = await fetch(`${BASE_URL}/models`, {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${API_KEY}`
      }
    })

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`)
    }

    const data = await response.json()
    return data.data || []
  } catch (error) {
    console.error('获取模型列表失败:', error)
    return []
  }
}
