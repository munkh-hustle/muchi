import 'package:muchi/data/memory.dart';

class MemoryData {
  static List<Memory> memories = [
    Memory(
      date: DateTime(2024, 12, 29),
      title: 'Our First Meeting 💖',
      highlights: [
        'Бидний анхны уулзалт',
        'Гар гараасаа барьсан 👫',
        'Бидний анхны үнсэлт 💋',
      ],
      fullStory:
          '''(2025.02.22-ны өдөр юу санаж байгаагаа бичиж байна, буруу санаж байж ч магадгүй) 
Би очихдоо автобусанд суулаа. Замдаа буух буудлаасаа нэг буудал өнгөрөөд явчихлаа. 
Тэгээд буцаж алхлаа. Хэхэ, бага зэрэг догдолж байсан юм аа. 
Профайл дээрээ "195 см 90 кг" гэсэн байсан лол. 
Би тэгээд очоод харлаа. Аххаха, нэлээн урт үстэй, өндөр залуу орцны гаднаас намайг тосоод авлаа. 
Бид хоёр "Сайн уу" гээд л, тэгээд цаашаа гэрт нь орлоо. 
Тэгээд бид хоёр кино үзэхээр болоод Интерстеллар киног үзлээ. 
Дундуур нь снэк болгоод хушга авчирч хажууд тавьчихлаа. 
Тэгээд тэр нэлээн нэрэлхүү байсан хэхэ. Ярьж байгаа нь гэхдээ аймаар таалагдсан. 
Тэгээд лаптопыг нь аваад нөгөө өөрийнх нь өрөөнд нь орж үзлээ. 
Тэгсэн гэнэт эвдрээд, гацаад унтарчихлаа...''',
      location: 'His apartment',
      loveRating: 5,
      mood: '😰', // Updated to emoji
      weather: '☁️', // Updated to emoji
      isMilestone: true,
      tags: ['#firstmeeting', '#nervous', '#specialnight'],
      secretNote: 'Тэр өдөр би үнэхээр их догдолж байсан... 💖',
    ),
  ];
  // ADD: Add a new memory
  static void addMemory(Memory memory) {
    memories.add(memory);
    memories.sort((a, b) => b.date.compareTo(a.date)); // Sort by newest first
  }

  // DELETE: Remove a memory
  static void deleteMemory(Memory memory) {
    memories.remove(memory);
  }

  // UPDATE: Update an existing memory
  static void updateMemory(Memory oldMemory, Memory newMemory) {
    final index = memories.indexOf(oldMemory);
    if (index != -1) {
      memories[index] = newMemory;
      memories.sort((a, b) => b.date.compareTo(a.date));
    }
  }

  // GET: Get memory by index
  static Memory getMemory(int index) {
    return memories[index];
  }
}
