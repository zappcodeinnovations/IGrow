class DummyEbook {
  final String id;
  final String title;
  final String author;
  final String description;
  final String pdfUrl;
  final String thumbnailUrl;

  const DummyEbook({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.pdfUrl,
    required this.thumbnailUrl,
  });
}

final List<DummyEbook> dummyEbooks = [
  DummyEbook(
    id: 'e1',
    title: 'Modern Agriculture Practices',
    author: 'Dr. John Doe',
    description: 'Learn about the latest modern practices in agriculture including hydroponics and precision farming.',
    pdfUrl: 'https://pdfobject.com/pdf/sample.pdf',
    thumbnailUrl: 'https://images.unsplash.com/photo-1628042973121-752a2292f767?q=80&w=300&auto=format&fit=crop',
  ),
  DummyEbook(
    id: 'e2',
    title: 'Organic Farming Guide',
    author: 'Jane Smith',
    description: 'A comprehensive guide to starting and maintaining a successful organic farm without chemical pesticides.',
    pdfUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
    thumbnailUrl: 'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?q=80&w=300&auto=format&fit=crop',
  ),
  DummyEbook(
    id: 'e3',
    title: 'Water Management & Irrigation',
    author: 'Prof. Alan Turing',
    description: 'Master the art of irrigation, saving water while maximizing crop yield.',
    pdfUrl: 'https://pdfobject.com/pdf/sample.pdf',
    thumbnailUrl: 'https://images.unsplash.com/photo-1560493676-04071c5f467b?q=80&w=300&auto=format&fit=crop',
  ),
];
