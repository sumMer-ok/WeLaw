import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

// Main Store
export const useMainStore = defineStore('main', () => {
  // State
  const user = ref({
    name: '法律学习者',
    avatar: '',
    streak: 15,
    totalCases: 128,
    totalVocab: 1250,
    masteredVocab: 850
  })

  const sidebarCollapsed = ref(false)
  const currentTheme = ref('light')

  // Getters
  const learningProgress = computed(() => ({
    cases: Math.round((user.value.totalCases / 200) * 100),
    vocab: Math.round((user.value.masteredVocab / user.value.totalVocab) * 100)
  }))

  // Actions
  const toggleSidebar = () => {
    sidebarCollapsed.value = !sidebarCollapsed.value
  }

  return {
    user,
    sidebarCollapsed,
    currentTheme,
    learningProgress,
    toggleSidebar
  }
})

// Cases Store
export const useCasesStore = defineStore('cases', () => {
  const cases = ref([
    {
      id: '1',
      title: 'Smith v. Jones',
      citation: '[2024] UKSC 1',
      court: 'Supreme Court',
      date: '2024-01-15',
      category: '合同法',
      status: '已掌握',
      summary: '合同违约与损害赔偿经典案例，涉及可预见性规则的适用',
      annotations: 12,
      tags: ['违约', '损害赔偿', '合同法', '可预见性'],
      lastRead: Date.now() - 86400000, // 昨天阅读
      readTime: 45, // 阅读时长（分钟）
      content: `
1 IN THE SUPREME COURT OF THE UNITED KINGDOM

2 Smith v. Jones

3 [2024] UKSC 1

4

5 Lord Smith delivered the judgment of the Court.

6

7 1. This appeal concerns the proper approach to the assessment of damages for breach of contract. The defendant breached the contract by failing to deliver the goods on time, causing significant loss to the plaintiff.

8

9 2. The central issue in this case is whether the plaintiff can recover damages for loss of profits that were not communicated to the defendant at the time of contract formation. The Hadley v. Baxendale (1854) 9 Exch 341 rule establishes that damages are recoverable if they arise naturally from the breach or were in the contemplation of both parties at the time of contract formation.

10

11 3. The facts of this case are straightforward. The parties entered into a contract for the sale of 100 tons of steel, with delivery scheduled for December 2023. The defendant failed to deliver on time, causing the plaintiff to lose a lucrative contract with a third party.

12

13 4. The defendant argues that the loss of profits was not foreseeable and therefore not recoverable. However, we find that in the ordinary course of business, delay in delivery of goods would naturally lead to loss of business opportunities. The plaintiff is entitled to recover the full amount of damages claimed.

14

15 5. For these reasons, we allow the appeal and hold that the defendant is liable for the full amount of damages claimed by the plaintiff.
      `
    },
    {
      id: '2',
      title: 'Hadley v. Baxendale',
      citation: '(1854) 9 Exch 341',
      court: 'Exchequer Court',
      date: '1854-02-23',
      category: '合同法',
      status: '学习中',
      summary: '确立了损害赔偿的可预见性规则，合同法里程碑案例',
      annotations: 8,
      tags: ['损害赔偿', '可预见性', '经典案例', '合同法'],
      lastRead: Date.now() - 172800000, // 前天阅读
      readTime: 60,
      content: `
1 IN THE COURT OF EXCHEQUER

2 Hadley v. Baxendale

3 (1854) 9 Exch 341

4

5 Alderson B delivered the judgment of the Court.

6

7 Where two parties have made a contract which one of them has broken, the damages which the other party ought to receive in respect of such breach of contract should be such as may fairly and reasonably be considered either arising naturally, i.e., according to the usual course of things, from such breach of contract itself, or such as may reasonably be supposed to have been in the contemplation of both parties, at the time they made the contract, as the probable result of the breach of it.

8

9 Now, if the special circumstances under which the contract was actually made were communicated by the plaintiffs to the defendants, and thus known to both parties, the damages resulting from the breach of such a contract, which they would reasonably contemplate, would be the amount of injury which would ordinarily follow from a breach of contract under these special circumstances so known and communicated.

10

11 But, on the other hand, if these special circumstances were wholly unknown to the party breaking the contract, he, at the most, could only be supposed to have had in his contemplation the amount of injury which would arise generally, and in the great multitude of cases not affected by any special circumstances, from such a breach of contract.
      `
    },
    {
      id: '3',
      title: 'Donoghue v. Stevenson',
      citation: '[1932] AC 562',
      court: 'House of Lords',
      date: '1932-05-26',
      category: '侵权法',
      status: '学习中',
      summary: '过失责任与注意义务的起源，现代侵权法基石',
      annotations: 15,
      tags: ['过失', '注意义务', '侵权法', '邻人原则'],
      lastRead: Date.now() - 259200000, // 3天前
      readTime: 90,
      content: `
1 IN THE HOUSE OF LORDS

2 Donoghue v. Stevenson

3 [1932] AC 562

4

5 Lord Atkin delivered the following speech:

6

7 My Lords, the sole question for determination in this case is legal: Do the averments made by the pursuer in her pleading, if true, disclose a cause of action?

8

9 The law of negligence has evolved over centuries, but the principle remains constant: You must take reasonable care to avoid acts or omissions which you can reasonably foresee would be likely to injure your neighbour.

10

11 Who, then, in law is my neighbour? The answer seems to be - persons who are so closely and directly affected by my act that I ought reasonably to have them in contemplation as being so affected when I am directing my mind to the acts or omissions which are called in question.

12

13 This statement of principle seems to me to be a sound statement of the law, and I adopt it as the basis of my judgment.
      `
    },
    {
      id: '4',
      title: 'Carlill v. Carbolic Smoke Ball',
      citation: '[1893] 1 QB 256',
      court: 'Court of Appeal',
      date: '1893-12-01',
      category: '合同法',
      status: '待学习',
      summary: '要约与承诺的经典案例，单方合同的重要判例',
      annotations: 0,
      tags: ['要约', '承诺', '对价', '单方合同'],
      lastRead: 0, // 未阅读
      readTime: 0,
      content: `
1 IN THE COURT OF APPEAL

2 Carlill v. Carbolic Smoke Ball Company

3 [1893] 1 QB 256

4

5 Lord Justice Lindley delivered the first judgment:

6

7 This is an action for breach of contract. The defendants are the proprietors of a medical preparation called "The Carbolic Smoke Ball." They advertised in various newspapers that they would pay £100 to any person who contracted influenza after having used their smoke ball three times daily for two weeks according to the printed directions supplied with each ball.

8

9 The plaintiff, on the faith of this advertisement, bought one of the balls and used it as directed. She nevertheless contracted influenza and claimed the £100.

10

11 The defendants contended that there was no contract between them and the plaintiff. They argued that their advertisement was a mere puff, not intended to create legal relations.

12

13 We are of opinion that the advertisement constituted an offer to the whole world, and that the performance of the conditions was the acceptance of that offer. The plaintiff is entitled to recover the £100.
      `
    },
    {
      id: '5',
      title: 'Brown v. Board of Education',
      citation: '347 U.S. 483',
      court: 'Supreme Court of the United States',
      date: '1954-05-17',
      category: '宪法',
      status: '已掌握',
      summary: '种族隔离与教育平等，美国民权运动的里程碑判决',
      annotations: 20,
      tags: ['宪法', '平等保护', '教育', '种族隔离'],
      lastRead: Date.now() - 345600000, // 4天前
      readTime: 120,
      content: `
1 IN THE SUPREME COURT OF THE UNITED STATES

2 Brown v. Board of Education of Topeka

3 347 U.S. 483 (1954)

4

5 Chief Justice Warren delivered the opinion of the Court.

6

7 These cases come to us from the States of Kansas, South Carolina, Virginia, and Delaware. They are premised on different facts and different local conditions, but a common legal question justifies their consideration together in this consolidated opinion.

8

9 In each of the cases, minors of the Negro race, through their legal representatives, seek the aid of the courts in obtaining admission to the public schools of their community on a nonsegregated basis. In each instance, they have been denied admission to schools attended by white children under laws requiring or permitting segregation according to race.

10

11 We conclude that in the field of public education the doctrine of "separate but equal" has no place. Separate educational facilities are inherently unequal. Therefore, we hold that the plaintiffs and others similarly situated for whom the actions have been brought are, by reason of the segregation complained of, deprived of the equal protection of the laws guaranteed by the Fourteenth Amendment.
      `
    }
  ])

  const categories = ['全部', '合同法', '侵权法', '刑法', '宪法', '证据法']

  const getCaseById = (id) => cases.value.find(c => c.id === id)

  return { cases, categories, getCaseById }
})

// Vocabulary Store
export const useVocabStore = defineStore('vocabulary', () => {
  const decks = ref([
    { id: '1', name: '基础法律术语', count: 350, review: 25, category: '基础' },
    { id: '2', name: '合同法词汇', count: 180, review: 12, category: '合同法' },
    { id: '3', name: '侵权法词汇', count: 150, review: 8, category: '侵权法' },
    { id: '4', name: '我的收藏', count: 45, review: 8, category: '收藏' }
  ])

  const todayStats = ref({
    new: 15,
    review: 32,
    mastered: 8,
    targetNew: 20,
    targetReview: 50
  })

  const currentCard = ref({
    id: '1',
    term: 'precedent',
    pronunciation: '/ˈpresɪdənt/',
    meaning: '先例；判例',
    definition: 'An earlier event or action that is regarded as an example or guide to be considered in subsequent similar circumstances.',
    example: 'This case could serve as a precedent for future employment disputes.',
    source: 'Brown v. Board of Education (1954)',
    tags: ['合同法', '判例法', '基础术语']
  })

  return { decks, todayStats, currentCard }
})

// Study Sets Store
export const useStudySetsStore = defineStore('studySets', () => {
  const studySets = ref([
    {
      id: '1',
      name: '合同法学习集',
      description: '合同法核心案例与概念整理',
      itemCount: 12,
      items: [
        { type: 'case', title: 'Smith v. Jones', subtitle: '合同违约与损害赔偿' },
        { type: 'case', title: 'Hadley v. Baxendale', subtitle: '损害赔偿可预见性规则' },
        { type: 'note', title: '合同法笔记', subtitle: '对价与违约救济要点总结' },
        { type: 'vocab', title: '合同法核心词汇', subtitle: '50张卡片待复习' }
      ],
      createdAt: '2024-01-15'
    },
    {
      id: '2',
      name: '侵权法专题',
      description: '过失责任与注意义务',
      itemCount: 8,
      items: [
        { type: 'case', title: 'Donoghue v. Stevenson', subtitle: '过失责任起源' },
        { type: 'case', title: 'Caparo v. Dickman', subtitle: '注意义务三阶段测试' },
        { type: 'note', title: '侵权法笔记', subtitle: '注意义务的限定' }
      ],
      createdAt: '2024-01-10'
    }
  ])

  return { studySets }
})

// AI Assistant Store
export const useAIStore = defineStore('ai', () => {
  const messages = ref([
    {
      role: 'assistant',
      content: '您好！我是EnofLaw AI助手。我可以帮您分析案例、解释法律概念或回答关于您案例库的问题。请问有什么可以帮您？',
      timestamp: new Date().toISOString()
    }
  ])

  const quickActions = [
    { label: '总结当前案例', icon: 'Document' },
    { label: '解释选中术语', icon: 'Collection' },
    { label: '比较相关案例', icon: 'ScaleToOriginal' },
    { label: '生成测验', icon: 'QuestionFilled' }
  ]

  const sendMessage = (content) => {
    messages.value.push({
      role: 'user',
      content,
      timestamp: new Date().toISOString()
    })

    // Simulate AI response
    setTimeout(() => {
      messages.value.push({
        role: 'assistant',
        content: `根据您的案例库，我来为您分析：\n\n【法律概念】Consideration 对价\n\n对价是合同成立的必备要素，指的是合同双方为换取对方承诺而付出的价值。\n\n在您收藏的案例中：\n1. Currie v. Misa (1875) - 经典对价定义\n2. Smith v. Jones - 其中提到："缺乏充分对价导致合同无法执行"\n\n关键要点：\n• 对价必须具有法律价值，但不需要充分(adequate)\n• 过去的对价通常不构成有效对价\n• 履行现有义务一般不构成对价`,
        timestamp: new Date().toISOString()
      })
    }, 1000)
  }

  return { messages, quickActions, sendMessage }
})
