-- EnofLaw Database Seed Data
-- Initial sample data

USE enoflaw;

-- Insert Users
INSERT INTO users (id, username, email, password_hash, avatar, settings) VALUES
('user-001', 'lawstudent', 'student@example.com', '$2a$10$N9qo8uLOickgx2ZMRZoMy.MqrqQzBZN0UfGNEsKYGs5q', NULL, '{"theme": "light", "language": "zh-CN"}'),
('user-002', 'lawyer', 'lawyer@example.com', '$2a$10$N9qo8uLOickgx2ZMRZoMy.MqrqQzBZN0UfGNEsKYGs5q', NULL, '{"theme": "dark", "language": "zh-CN"}');

-- Insert Folders
INSERT INTO folders (id, name, parent_id, icon, color, sort_order, created_by) VALUES
('folder-001', 'Contract Law', NULL, 'Document', '#8B4513', 1, 'user-001'),
('folder-002', 'Tort Law', NULL, 'Document', '#5A7D5A', 2, 'user-001'),
('folder-003', 'Criminal Law', NULL, 'Document', '#8B0000', 3, 'user-001'),
('folder-004', 'Constitutional Law', NULL, 'Document', '#B8860B', 4, 'user-001'),
('folder-005', 'Contract Formation', 'folder-001', 'Folder', '#8B4513', 1, 'user-001'),
('folder-006', 'Breach and Remedies', 'folder-001', 'Folder', '#8B4513', 2, 'user-001');

-- Insert Cases
INSERT INTO cases (id, title, citation, court, judgment_date, parties, case_number, judges, full_text, summary, key_facts, holding, reasoning, ai_analysis, folder_id, tags, category, status, priority, file_path, file_type, page_count, word_count, created_by) VALUES
('case-001', 'Smith v. Jones', '[2024] UKSC 1', 'Supreme Court', '2024-01-15', '{"plaintiff": "Smith", "defendant": "Jones"}', 'UKSC 2024/1', '["Lord Smith", "Lady Jones", "Lord Brown"]', 
'IN THE SUPREME COURT OF THE UNITED KINGDOM

Smith v. Jones
[2024] UKSC 1

Lord Smith delivered the judgment of the Court.

1. This appeal concerns the proper approach to the assessment of damages for breach of contract. The defendant breached the contract by failing to deliver the goods on time, causing significant loss to the plaintiff.

2. The central issue in this case is whether the plaintiff can recover damages for loss of profits that were not communicated to the defendant at the time of contract formation. The Hadley v. Baxendale rule establishes that damages are recoverable for losses that arise naturally and ordinarily from the breach.

3. The facts of this case are straightforward. The parties entered into a contract for the sale of 100 tons of steel, with delivery scheduled for December 2023. The defendant failed to deliver on time, and the plaintiff suffered loss of profits as a result.

4. The defendant argues that the loss of profits was not foreseeable and therefore not recoverable. However, we find that in the ordinary course of business, delay in delivery of goods would naturally lead to loss of profits.

5. For these reasons, we allow the appeal and hold that the defendant is liable for the full amount of damages claimed by the plaintiff.',
'Contract breach and damages case establishing foreseeability rule in commercial contracts',
'["Contract for 100 tons of steel", "Delivery scheduled for December 2023", "Defendant failed to deliver on time", "Plaintiff suffered loss of profits"]',
'Defendant committed fundamental breach and is liable for plaintiff loss of profits',
'Court held that in commercial activities, delay in delivery naturally leads to loss of profits, which is a natural and probable result of breach, consistent with Hadley v. Baxendale rule',
'{"issues": ["Whether the defendant breached the contract", "Whether the plaintiff can recover damages for loss of profits"], "rules": ["Hadley v. Baxendale Rule: Damages are recoverable for losses that arise naturally and ordinarily from the breach"], "facts": ["Contract for 100 tons of steel", "Delivery scheduled for December 2023", "Defendant failed to deliver on time"], "holding": "Defendant is liable for the full amount of damages", "rationale": "Delay in delivery naturally leads to loss of profits in ordinary course of business"}',
'folder-006',
'["breach", "damages", "contract", "foreseeability"]',
'Contract Law',
'learning',
'high',
'/cases/smith_v_jones.pdf',
'pdf',
15,
3500,
'user-001'),

('case-002', 'Hadley v. Baxendale', '(1854) 9 Exch 341', 'Exchequer Court', '1854-02-23', '{"plaintiff": "Hadley", "defendant": "Baxendale"}', '1854 Ex 341', '["Alderson B", "Parke B", "Martin B"]', 
'In the Exchequer Court

Hadley v. Baxendale
(1854) 9 Exch 341

Alderson B delivered the judgment of the Court.

This was an action for breach of contract. The plaintiffs were millers. The crankshaft of their mill broke, stopping production. They delivered the broken shaft to the defendants, who were carriers, to be sent to the manufacturer for a new shaft to be made. The defendants delayed delivery, causing the plaintiffs loss of profits.

The question raised was whether the damages claimed were too remote. We think that the damages should be such as may fairly and reasonably be considered either arising naturally, i.e., according to the usual course of things, from such breach of contract itself, or such as may reasonably be supposed to have been in the contemplation of both parties, at the time they made the contract, as the probable result of the breach of it.',
'Established the rule of foreseeability in damages, one of the most important contract cases in common law',
'["Plaintiffs were millers", "Crankshaft broke stopping production", "Defendants were carriers", "Defendants delayed delivery causing loss of profits"]',
'Established the rule of foreseeability of damages (Hadley Rule)',
'Damages should be limited to: (1) losses arising naturally in the usual course of things; (2) losses reasonably foreseeable by both parties at the time of contract formation',
'{"issues": ["Whether the damages claimed were too remote"], "rules": ["Hadley Rule: Damages should be such as may fairly and reasonably be considered arising naturally from breach or in contemplation of parties"], "facts": ["Plaintiffs were millers", "Crankshaft broke stopping production", "Defendants were carriers who delayed delivery"], "holding": "Established the rule of remoteness of damage in contract", "rationale": "Damages limited to what arises naturally or was in contemplation of parties"}',
'folder-006',
'["damages", "foreseeability", "classic", "contract"]',
'Contract Law',
'mastered',
'high',
'/cases/hadley_v_baxendale.pdf',
'pdf',
8,
1800,
'user-001'),

('case-003', 'Donoghue v. Stevenson', '[1932] AC 562', 'House of Lords', '1932-05-26', '{"plaintiff": "Donoghue", "defendant": "Stevenson"}', '1932 AC 562', '["Lord Atkin", "Lord Thankerton", "Lord Macmillan"]', 
'In the House of Lords

Donoghue v. Stevenson
[1932] AC 562

Lord Atkin delivered the leading judgment.

The appellant, Mrs. Donoghue, consumed ginger beer manufactured by the respondent, Stevenson. The bottle contained the decomposed remains of a snail. She alleged that she suffered from shock and severe gastro-enteritis. She could not sue in contract as she had not purchased the drink herself. The question was whether the manufacturer owed a duty of care to the ultimate consumer.

We must have a duty of care to avoid acts or omissions which you can reasonably foresee would be likely to injure your neighbour. Who, then, in law is my neighbour? The answer seems to be - persons who are so closely and directly affected by my act that I ought reasonably to have them in contemplation as being so affected when I am directing my mind to the acts or omissions which are called in question.',
'Origin of negligence liability and duty of care, established the neighbour principle in modern tort law',
'["Plaintiff consumed defendant manufactured ginger beer", "Bottle contained decomposed snail", "Plaintiff suffered shock and gastro-enteritis", "No contractual relationship"]',
'Manufacturer owes duty of care to ultimate consumer',
'Established the neighbour principle: You must have a duty of care to avoid acts or omissions likely to injure those you can reasonably foresee would be affected',
'{"issues": ["Whether the manufacturer owed a duty of care to the ultimate consumer"], "rules": ["Neighbour Principle: Duty of care to avoid acts or omissions likely to injure those closely and directly affected"], "facts": ["Bottle contained decomposed snail", "Plaintiff suffered shock and gastro-enteritis", "No contractual relationship"], "holding": "Manufacturer owes duty of care to ultimate consumer", "rationale": "Established the neighbour principle in negligence"}',
'folder-002',
'["negligence", "duty of care", "tort", "neighbour principle", "classic"]',
'Tort Law',
'learning',
'high',
'/cases/donoghue_v_stevenson.pdf',
'pdf',
25,
5200,
'user-001'),

('case-004', 'Carlill v. Carbolic Smoke Ball Company', '[1893] 1 QB 256', 'Court of Appeal', '1892-12-01', '{"plaintiff": "Carlill", "defendant": "Carbolic Smoke Ball Company"}', '1893 1 QB 256', '["Lord Justice Lindley", "Lord Justice Bowen", "Lord Justice AL Smith"]', 
'In the Court of Appeal

Carlill v. Carbolic Smoke Ball Company
[1893] 1 QB 256

The defendants advertised that they would pay £100 to anyone who contracted influenza after using their product according to directions. The plaintiff used the product as directed but still contracted influenza. She claimed the £100.

The defendants argued that there was no contract because the plaintiff had not communicated acceptance. However, we find that this was a unilateral offer which could be accepted by performance. The advertisement was an offer to the whole world, and the performance of the condition was the acceptance.

The promise is binding because the defendants received a benefit from the use of their product by the public, and the plaintiff acted to her detriment in reliance on the promise.',
'Classic case on offer and acceptance, established the concept of unilateral contract',
'["Defendant advertised to pay £100", "Plaintiff used product as directed but still got flu", "Defendant argued no contract without communication of acceptance", "Court found unilateral offer can be accepted by performance"]',
'Advertisement constitutes offer, use of product constitutes acceptance, contract formed',
'Advertisement is an offer to the whole world, performance of condition is acceptance. Defendant benefited from public use, plaintiff acted in reliance on promise',
'{"issues": ["Whether there was a binding contract", "Whether advertisement was an offer"], "rules": ["Unilateral offer can be accepted by performance", "Advertisement can be offer to the whole world"], "facts": ["Advertisement promised £100", "Plaintiff used product as directed", "Defendants argued no communication of acceptance"], "holding": "Advertisement was offer, performance was acceptance", "rationale": "Unilateral contract formed by performance of condition"}',
'folder-005',
'["offer", "acceptance", "consideration", "unilateral contract", "classic"]',
'Contract Law',
'pending',
'high',
'/cases/carlill_v_carbolic.pdf',
'pdf',
12,
2800,
'user-001'),

('case-005', 'Brown v. Board of Education', '347 U.S. 483', 'Supreme Court of the United States', '1954-05-17', '{"plaintiff": "Brown", "defendant": "Board of Education of Topeka"}', '347 U.S. 483', '["Chief Justice Warren", "Justice Black", "Justice Douglas"]', 
'In the Supreme Court of the United States

Brown v. Board of Education of Topeka
347 U.S. 483 (1954)

Chief Justice Warren delivered the opinion of the Court.

These cases come to us from the States of Kansas, South Carolina, Virginia, and Delaware. They are premised on different facts and different local conditions, but a common legal question justifies their consideration together in this consolidated opinion.

Does segregation of children in public schools solely on the basis of race, even though the physical facilities and other "tangible" factors may be equal, deprive the children of the minority group of equal educational opportunities? We believe that it does.

To separate them from others of similar age and qualifications solely because of their race generates a feeling of inferiority as to their status in the community that may affect their hearts and minds in a way unlikely ever to be undone. We conclude that in the field of public education the doctrine of "separate but equal" has no place. Separate educational facilities are inherently unequal.',
'Landmark case on racial segregation and educational equality, overturned the "separate but equal" doctrine',
'["Plaintiffs were African American students", "Defendant was Board of Education", "Public schools practiced racial segregation", "Facilities equal but educational opportunities not equal"]',
'Racial segregation in public schools violates the Equal Protection Clause of the Fourteenth Amendment',
'Segregation generates feelings of inferiority in minority children, affecting their hearts and minds. In public education, the "separate but equal" doctrine has no place; separate educational facilities are inherently unequal',
'{"issues": ["Whether segregation in public schools violates Equal Protection Clause"], "rules": ["Separate but equal has no place in public education", "Segregation generates feeling of inferiority"], "facts": ["Segregation in public schools", "Facilities were equal", "Children of minority group affected"], "holding": "Segregation in public schools is unconstitutional", "rationale": "Separate educational facilities are inherently unequal"}',
'folder-004',
'["constitutional", "equal protection", "education", "segregation", "landmark"]',
'Constitutional Law',
'mastered',
'high',
'/cases/brown_v_board.pdf',
'pdf',
30,
6800,
'user-001');

-- Insert Annotations
INSERT INTO annotations (id, case_id, type, position, content, color, tags, created_by) VALUES
('anno-001', 'case-001', 'highlight', '{"startParagraph": 1, "startOffset": 0, "endParagraph": 1, "endOffset": 100, "text": "The defendant breached the contract by failing to deliver the goods on time"}', 'Key breach fact', '#FFD700', '["breach", "important"]', 'user-001'),
('anno-002', 'case-001', 'note', '{"startParagraph": 2, "startOffset": 0, "endParagraph": 2, "endOffset": 50, "text": "Hadley v. Baxendale rule"}', 'Classic damages rule, must master', '#E8D4C4', '["legal rule", "classic case"]', 'user-001'),
('anno-003', 'case-002', 'highlight', '{"startParagraph": 0, "startOffset": 0, "endParagraph": 0, "endOffset": 80, "text": "damages should be such as may fairly and reasonably be considered"}', 'Core Hadley rule statement', '#FFD700', '["core rule", "must memorize"]', 'user-001'),
('anno-004', 'case-003', 'underline', '{"startParagraph": 2, "startOffset": 0, "endParagraph": 2, "endOffset": 120, "text": "duty of care to avoid acts or omissions which you can reasonably foresee"}', 'Core neighbour principle statement', '#3B82F6', '["neighbour principle", "core concept"]', 'user-001'),
('anno-005', 'case-003', 'note', '{"startParagraph": 2, "startOffset": 0, "endParagraph": 2, "endOffset": 200, "text": "persons who are so closely and directly affected"}', 'Neighbour definition: closely and directly affected persons', '#E8D4C4', '["neighbour definition", "important"]', 'user-001');

-- Insert Decks
INSERT INTO decks (id, name, description, category, is_built_in, card_count, created_by) VALUES
('deck-001', 'Basic Legal Terms', 'Most commonly used terms in legal study', 'Basic', TRUE, 350, 'system'),
('deck-002', 'Contract Law Terms', 'Professional terms in contract law', 'Contract', TRUE, 180, 'system'),
('deck-003', 'Tort Law Terms', 'Professional terms in tort law', 'Tort', TRUE, 150, 'system'),
('deck-004', 'Criminal Law Terms', 'Professional terms in criminal law', 'Criminal', TRUE, 200, 'system'),
('deck-005', 'My Collection', 'User collected vocabulary', 'Collection', FALSE, 45, 'user-001');

-- Insert Vocabulary
INSERT INTO vocabulary (id, term, pronunciation, part_of_speech, difficulty, definition, chinese_meaning, legal_explanation, field, deck_id, srs_data, mastery_level, review_count, correct_count, wrong_count, last_review_date, next_review_date, created_by) VALUES
('vocab-001', 'precedent', '/ˈpresɪdənt/', 'noun', 'basic', 'An earlier event or action that is regarded as an example or guide to be considered in subsequent similar circumstances.', '先例；判例', 'In legal systems, prior court decisions that are binding or persuasive for subsequent similar cases', 'Case Law', 'deck-001', '{"interval": 6, "repetition": 3, "easeFactor": 2.5, "nextReviewDate": "2024-02-25"}', 85, 12, 10, 2, '2024-02-19', '2024-02-25', 'user-001'),

('vocab-002', 'jurisdiction', '/ˌdʒʊərɪsˈdɪkʃn/', 'noun', 'basic', 'The official power to make legal decisions and judgments.', '管辖权；司法权', 'The power of a court or legal authority to hear and decide cases in a particular geographic area or over certain types of cases', 'Procedure', 'deck-001', '{"interval": 1, "repetition": 1, "easeFactor": 2.0, "nextReviewDate": "2024-02-21"}', 30, 3, 2, 1, '2024-02-20', '2024-02-21', 'user-001'),

('vocab-003', 'negligence', '/ˈneɡlɪdʒəns/', 'noun', 'intermediate', 'Failure to take proper care in doing something, resulting in damage or injury to another.', '过失；疏忽', 'In tort law, conduct that falls below the standard of care that a reasonable person would exercise, causing harm to others', 'Tort', 'deck-003', '{"interval": 4, "repetition": 2, "easeFactor": 2.3, "nextReviewDate": "2024-02-24"}', 60, 8, 6, 2, '2024-02-20', '2024-02-24', 'user-001'),

('vocab-004', 'consideration', '/kənˌsɪdəˈreɪʃn/', 'noun', 'intermediate', 'Something of value promised or given in exchange for something else in a contract.', '对价；约因', 'In contract law, something of value given by one party to another in exchange for a promise, essential element for contract formation', 'Contract', 'deck-002', '{"interval": 10, "repetition": 4, "easeFactor": 2.6, "nextReviewDate": "2024-03-01"}', 90, 15, 14, 1, '2024-02-19', '2024-03-01', 'user-001'),

('vocab-005', 'breach', '/briːtʃ/', 'noun', 'basic', 'An act of breaking or failing to observe a law, agreement, or code of conduct.', '违反；违约；破坏', 'Failure to perform a legal obligation or comply with the terms of a contract', 'Contract', 'deck-002', '{"interval": 6, "repetition": 3, "easeFactor": 2.5, "nextReviewDate": "2024-02-26"}', 80, 10, 9, 1, '2024-02-20', '2024-02-26', 'user-001'),

('vocab-006', 'damages', '/ˈdæmɪdʒɪz/', 'noun', 'intermediate', 'A sum of money claimed or awarded in compensation for a loss or an injury.', '损害赔偿金', 'Money awarded by a court to a plaintiff to compensate for losses suffered due to breach of contract or tort', 'Contract', 'deck-002', '{"interval": 3, "repetition": 2, "easeFactor": 2.2, "nextReviewDate": "2024-02-23"}', 55, 6, 5, 1, '2024-02-20', '2024-02-23', 'user-001'),

('vocab-007', 'liability', '/ˌlaɪəˈbɪləti/', 'noun', 'intermediate', 'The state of being legally responsible for something.', '责任；义务；赔偿责任', 'Legal responsibility for an act or event under the law', 'Tort', 'deck-003', '{"interval": 1, "repetition": 1, "easeFactor": 2.0, "nextReviewDate": "2024-02-21"}', 25, 2, 1, 1, '2024-02-20', '2024-02-21', 'user-001'),

('vocab-008', 'tort', '/tɔːt/', 'noun', 'intermediate', 'A wrongful act or an infringement of a right leading to civil legal liability.', '侵权行为', 'A civil wrong that causes someone else to suffer loss or harm, excluding breach of contract, resulting in legal liability', 'Tort', 'deck-003', '{"interval": 6, "repetition": 3, "easeFactor": 2.5, "nextReviewDate": "2024-02-26"}', 75, 9, 8, 1, '2024-02-20', '2024-02-26', 'user-001');

-- Insert Vocabulary Examples
INSERT INTO vocabulary_examples (id, vocabulary_id, sentence, translation, source, case_id, paragraph_number, is_user_added) VALUES
('ex-001', 'vocab-001', 'This case could serve as a precedent for future employment disputes.', '本案可作为未来劳动争议的先例。', 'Brown v. Board of Education (1954)', 'case-005', 5, FALSE),
('ex-002', 'vocab-001', 'The court followed the precedent established in the earlier case.', '法院遵循了先前案例确立的先例。', 'Smith v. Jones (2024)', 'case-001', 3, FALSE),
('ex-003', 'vocab-002', 'The court has jurisdiction over all criminal matters in this district.', '本法院对本区所有刑事案件具有管辖权。', 'Smith v. Jones (2024)', 'case-001', 1, FALSE),
('ex-004', 'vocab-003', 'The defendant was found liable for negligence in maintaining the premises.', '被告因在维护场所方面存在过失而被判承担责任。', 'Donoghue v. Stevenson (1932)', 'case-003', 2, FALSE),
('ex-005', 'vocab-004', 'The contract is unenforceable for lack of consideration.', '因缺乏对价，该合同无法执行。', 'Currie v. Misa (1875)', NULL, NULL, FALSE),
('ex-006', 'vocab-005', 'The defendant breached the contract by failing to deliver on time.', '被告因未能按时交付而违反了合同。', 'Smith v. Jones (2024)', 'case-001', 1, FALSE),
('ex-007', 'vocab-006', 'The plaintiff claimed damages for loss of profits.', '原告就利润损失索赔损害赔偿金。', 'Hadley v. Baxendale (1854)', 'case-002', 2, FALSE),
('ex-008', 'vocab-008', 'The defendant committed a tort by negligently causing injury.', '被告因过失造成伤害而构成侵权行为。', 'Donoghue v. Stevenson (1932)', 'case-003', 3, FALSE);

-- Insert Vocabulary Tags
INSERT INTO vocabulary_tags (id, vocabulary_id, tag) VALUES
('tag-001', 'vocab-001', 'Case Law'),
('tag-002', 'vocab-001', 'Basic Term'),
('tag-003', 'vocab-002', 'Procedure'),
('tag-004', 'vocab-002', 'Basic Term'),
('tag-005', 'vocab-003', 'Tort'),
('tag-006', 'vocab-003', 'Core Concept'),
('tag-007', 'vocab-004', 'Contract'),
('tag-008', 'vocab-004', 'Core Concept'),
('tag-009', 'vocab-005', 'Contract'),
('tag-010', 'vocab-005', 'Basic Term'),
('tag-011', 'vocab-006', 'Contract'),
('tag-012', 'vocab-006', 'Remedy'),
('tag-013', 'vocab-007', 'Tort'),
('tag-014', 'vocab-008', 'Tort'),
('tag-015', 'vocab-008', 'Core Concept');

-- Insert Study Sets
INSERT INTO study_sets (id, name, description, cover_image, tags, item_count, created_by) VALUES
('set-001', 'Contract Law Study Set', 'Core cases and concepts in contract law', NULL, '["contract", "core concept", "case"]', 12, 'user-001'),
('set-002', 'Tort Law Special Topic', 'Negligence liability and duty of care', NULL, '["tort", "negligence", "duty of care"]', 8, 'user-001'),
('set-003', 'Common Law Classic Cases', 'Landmark cases in common law history', NULL, '["classic case", "landmark", "history"]', 15, 'user-001');

-- Insert Study Set Items
INSERT INTO study_set_items (id, study_set_id, item_type, entity_id, title, item_order) VALUES
('item-001', 'set-001', 'case', 'case-001', 'Smith v. Jones', 1),
('item-002', 'set-001', 'case', 'case-002', 'Hadley v. Baxendale', 2),
('item-003', 'set-001', 'case', 'case-004', 'Carlill v. Carbolic Smoke Ball', 3),
('item-004', 'set-001', 'vocab', 'vocab-004', 'Consideration', 4),
('item-005', 'set-001', 'vocab', 'vocab-005', 'Breach', 5),
('item-006', 'set-001', 'vocab', 'vocab-006', 'Damages', 6),
('item-007', 'set-002', 'case', 'case-003', 'Donoghue v. Stevenson', 1),
('item-008', 'set-002', 'vocab', 'vocab-003', 'Negligence', 2),
('item-009', 'set-002', 'vocab', 'vocab-007', 'Liability', 3),
('item-010', 'set-002', 'vocab', 'vocab-008', 'Tort', 4),
('item-011', 'set-003', 'case', 'case-002', 'Hadley v. Baxendale', 1),
('item-012', 'set-003', 'case', 'case-003', 'Donoghue v. Stevenson', 2),
('item-013', 'set-003', 'case', 'case-004', 'Carlill v. Carbolic Smoke Ball', 3),
('item-014', 'set-003', 'case', 'case-005', 'Brown v. Board of Education', 4);

-- Insert Notes
INSERT INTO notes (id, title, content, case_id, study_set_id, created_by) VALUES
('note-001', 'Contract Law Notes - Consideration Principle', '{"blocks": [{"type": "heading", "content": "Consideration Principle"}, {"type": "text", "content": "Consideration is an essential element for contract formation, referring to the value exchanged between parties for mutual promises."}, {"type": "heading", "content": "Key Points"}, {"type": "list", "items": ["Consideration must have legal value but need not be adequate", "Past consideration is generally not valid", "Performance of existing duties generally does not constitute consideration"]}]}', NULL, 'set-001', 'user-001'),

('note-002', 'Tort Law Notes - Duty of Care', '{"blocks": [{"type": "heading", "content": "Duty of Care"}, {"type": "text", "content": "Duty of care is the core element of negligence tort, originating from the neighbour principle established in Donoghue v. Stevenson."}, {"type": "heading", "content": "Neighbour Principle"}, {"type": "quote", "content": "You must take reasonable care to avoid acts or omissions which you can reasonably foresee would be likely to injure your neighbour."}, {"type": "heading", "content": "Caparo Three-Stage Test"}, {"type": "list", "items": ["Foreseeability of damage", "Proximity of relationship", "Fairness, justice and reasonableness"]}]}', 'case-003', 'set-002', 'user-001'),

('note-003', 'Damages Rule Summary', '{"blocks": [{"type": "heading", "content": "Hadley v. Baxendale Rule"}, {"type": "text", "content": "Damages should be limited to the following two categories:"}, {"type": "list", "items": ["Losses arising naturally in the usual course of things", "Losses reasonably foreseeable by both parties at the time of contract formation"]}, {"type": "heading", "content": "Victoria Laundry Development"}, {"type": "text", "content": "Restated the two categories in Hadley rule as:"}, {"type": "list", "items": ["Ordinary damages: Natural result of breach", "Special damages: Foreseeable loss after being informed of specific circumstances"]}]}', 'case-002', 'set-001', 'user-001');

-- Insert Relationships
INSERT INTO relationships (id, source_id, source_type, target_id, target_type, relation_type, description, is_bidirectional, created_by) VALUES
('rel-001', 'case-001', 'case', 'case-002', 'case', 'follows', 'Smith case follows Hadley rule on damages', TRUE, 'user-001'),
('rel-002', 'vocab-004', 'vocabulary', 'case-004', 'case', 'related', 'Consideration concept discussed in Carlill case', TRUE, 'user-001'),
('rel-003', 'vocab-003', 'vocabulary', 'case-003', 'case', 'related', 'Negligence concept established in Donoghue case', TRUE, 'user-001'),
('rel-004', 'note-003', 'note', 'case-002', 'case', 'related', 'Note summarizes Hadley case damages rule', TRUE, 'user-001'),
('rel-005', 'case-001', 'case', 'vocab-005', 'vocabulary', 'related', 'Breach of contract is core issue in Smith case', TRUE, 'user-001');

-- Insert AI Queries
INSERT INTO ai_queries (id, query, response, context, model, tokens_used, is_favorite, created_by) VALUES
('query-001', 'Explain the concept of consideration in contract law', 'Based on your case library, let me explain the concept of consideration:

【Legal Concept】Consideration

Consideration is an essential element for contract formation, referring to the value exchanged between parties for mutual promises.

In your collected cases:
1. Currie v. Misa (1875) - Classic consideration definition
2. Smith v. Jones - Mentioned: "Lack of adequate consideration makes contract unenforceable"

Key Points:
• Consideration must have legal value but need not be adequate
• Past consideration is generally not valid
• Performance of existing duties generally does not constitute consideration', '{"caseIds": ["case-004"], "vocabIds": ["vocab-004"]}', 'gpt-4', 450, TRUE, 'user-001'),

('query-002', 'Summarize the holding in Smith v. Jones', '【Case Summary】Smith v. Jones (2024)

📋 Facts:
Plaintiff Smith and Defendant Jones entered into a contract for sale of goods, with Jones scheduled to deliver 100 tons of steel in December 2023. Jones failed to deliver on time, and Smith sued for damages.

⚖️ Issues:
1. Did the defendant commit breach?
2. How should damages be calculated?

📝 Holding:
1. Defendant committed material breach
2. Plaintiff claim for damages is upheld
3. Damages awarded for expectation interest

📌 Reasoning:
Court cited Hadley v. Baxendale rule, finding plaintiff loss was natural and probable result of breach, which defendant should have foreseen.', '{"caseIds": ["case-001", "case-002"]}', 'gpt-4', 380, FALSE, 'user-001');
