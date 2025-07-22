# Comprehensive Sports Video Analysis Dataset: Multi-Sport Broadcast Collection for Computer Vision Research

[![Dataset](https://img.shields.io/badge/Dataset-Sports%20Video-blue.svg)](https://github.com/abdkhanstd/Sports)
[![Paper](https://img.shields.io/badge/Paper-Neural%20Processing%20Letters-green.svg)](https://link.springer.com/article/10.1007/s11063-020-10251-4)
[![SPIE](https://img.shields.io/badge/Conference-SPIE%20ISAIR%202020-orange.svg)](https://www.spiedigitallibrary.org/)
[![Size](https://img.shields.io/badge/Size-105GB-red.svg)](README.md)
[![Duration](https://img.shields.io/badge/Duration-230%2B%20Hours-purple.svg)](README.md)

## Abstract

This repository presents a meticulously curated collection of broadcast sports videos specifically assembled to advance computer vision research in sports analytics, video summarization, and automated content analysis. The dataset encompasses **104 full-length sports videos** with a cumulative duration exceeding **230 hours**, representing an unprecedented resource for developing and evaluating machine learning algorithms in the sports domain.

Our collection methodology prioritized ecological validity by capturing videos in their natural broadcast environment, including commercial interruptions, network logos, and viewer-generated overlays that reflect authentic consumption contexts. This approach ensures that algorithms developed using this dataset will demonstrate robust performance when deployed in real-world sports broadcasting scenarios, where pristine laboratory conditions rarely exist.

The dataset's comprehensive scope spans **12 distinct sports categories**, carefully selected to represent diverse temporal structures, scoring mechanisms, and visual complexities inherent in modern sports broadcasting. From time-constrained competitions like basketball and soccer to score-driven formats such as cricket and baseball, this collection enables researchers to develop generalizable approaches that transcend sport-specific constraints.

## Dataset Composition and Statistical Analysis

### Comprehensive Sports Coverage

Our dataset demonstrates strategic diversity across multiple dimensions of sports broadcasting complexity. The temporal distribution reflects authentic broadcast patterns, with longer-duration sports like cricket naturally contributing more extensive coverage while maintaining balanced representation across all categories.

| Sport Category | Video Count | Frame Rate (fps) | Cumulative Duration | Average Duration |
|----------------|-------------|------------------|-------------------|------------------|
| Cricket | 11 | 23–30 | 42:23 | 3:51 |
| Soccer | 22 | 23–30 | 39:08 | 1:47 |
| Rugby | 10 | 23–30 | 21:28 | 2:09 |
| Basketball | 11 | 25–30 | 17:59 | 1:38 |
| Football | 8 | 25–30 | 18:51 | 2:21 |
| Baseball | 7 | 25–30 | 18:21 | 2:37 |
| Tennis | 7 | 27–30 | 17:14 | 2:28 |
| Ice Hockey | 7 | 25–30 | 16:07 | 2:18 |
| Handball | 9 | 24–30 | 12:11 | 1:21 |
| Hockey | 4 | 25–30 | 8:04 | 2:01 |
| Snooker | 4 | 25–30 | 6:07 | 1:32 |
| Volleyball | 4 | 25–25 | 5:48 | 1:27 |

### Technical Specifications

All videos maintain **MP4 encoding** with frame rates spanning **23–30 fps**, ensuring compatibility with standard video processing pipelines while preserving temporal fidelity essential for motion analysis. The frame rate variations reflect authentic broadcast standards across different sports and broadcasting networks, providing researchers with realistic technical constraints encountered in production environments.

## Visual Complexity and Research Challenges

### Representative Frame Samples
![Dataset Visual Complexity](https://raw.githubusercontent.com/abdkhanstd/Sports/master/samples.jpg)
*Illustrative frame samples demonstrating the inherent visual complexity of broadcast sports videos, including background clutter, 3D marketing overlays, and dynamic camera movements that challenge conventional computer vision approaches*

The visual samples clearly illustrate the substantial challenges inherent in sports video analysis. These complexities include dense background clutter from spectator areas, dynamically rendered 3D marketing elements integrated into playing surfaces, and sophisticated camera work involving rapid panning, zooming, and perspective changes that significantly complicate automated analysis tasks.

Sports broadcasting environments present unique computational challenges rarely encountered in controlled laboratory settings. The presence of superimposed graphics, variable lighting conditions, and complex multi-object interactions creates demanding scenarios for object detection, tracking, and event recognition algorithms. These authentic conditions ensure that methods validated on our dataset will demonstrate robust performance in real-world deployment scenarios.

## Data Access and Distribution

### Primary Video Collection
**Complete Video Dataset** (~105 GB):
Access the full collection of broadcast sports videos through our institutional cloud storage infrastructure:
- [Primary Video Archive](https://stduestceducn-my.sharepoint.com/:f:/g/personal/201714060114_std_uestc_edu_cn/EsYRaX2slJ1EjrMe-7SdZeQBB8dh3Wo_bHJrSAu8o5Uj0g?e=0XNfJe)

### Auxiliary Audio Resources
**Pre-extracted Audio Files** (MP3 format):
Synchronized audio components extracted for multimodal analysis applications:
- [Audio Component Archive](https://stduestceducn-my.sharepoint.com/:f:/g/personal/201714060114_std_uestc_edu_cn/Eu_uKfUiHpVBn3Y8N5s9UmoBZrJC0xzLbPnIfAB16URDRw?e=BbPqbd)

The audio extraction process employed standardized sampling rates and compression algorithms to maintain temporal alignment with corresponding video sequences. These audio files enable researchers to explore sophisticated multimodal approaches combining visual and auditory features for enhanced sports analysis capabilities.

## Annotation Framework and Ground Truth Data

### Scorebox Detection and Localization

The dataset includes comprehensive ground truth annotations for scorebox detection and localization tasks, stored in structured JSON format within the "scorebox availability and location" directory. Each annotation file provides temporal and spatial information essential for training and evaluating automated scorebox recognition systems.

**Annotation Schema**:
- **Temporal Information**: Frame-accurate timestamps (seconds) indicating scorebox presence
- **Spatial Coordinates**: Bounding box parameters (Ymin, Ymax, Xmin, Xmax) defining scorebox location
- **Availability Status**: Binary indicators for scorebox presence/absence across video sequences

The coordinate system employs standard image indexing conventions, with Ymin/Ymax representing vertical boundaries and Xmin/Xmax defining horizontal extents. This annotation framework enables precise evaluation of object detection algorithms while facilitating comparative analysis across different methodological approaches.

### Event Detection Annotations

Comprehensive event timing information is provided through structured JSON files located in the Events directory. These annotations capture the temporal boundaries of significant sports events, enabling researchers to develop and evaluate automated highlight generation and event detection systems.

Event annotations employ precise temporal markers indicating start and end times relative to video timestamps, facilitating the development of algorithms for automatic sports summarization and key moment identification. The annotation methodology prioritized consistency across annotators while maintaining sports-specific event definitions relevant to each category.

## Research Applications and Methodological Opportunities

This dataset enables diverse research directions spanning computer vision, machine learning, and sports analytics. Primary applications include automated video summarization, real-time event detection, scoreboard recognition, and multimodal content analysis combining visual and auditory information streams.

The comprehensive temporal coverage and authentic broadcast conditions support the development of robust algorithms capable of handling real-world deployment challenges. Researchers can leverage this resource for investigating novel architectures, transfer learning approaches, and domain adaptation techniques specifically tailored for sports video analysis applications.

### Potential Research Directions

**Computer Vision Applications**:
- Object detection and tracking in dynamic sports environments
- Semantic segmentation of playing fields and player identification
- Camera motion analysis and stabilization for broadcast content
- Automated scoreboard and graphics recognition systems

**Machine Learning Methodologies**:
- Temporal action recognition across diverse sports contexts
- Multi-stream neural architectures for video understanding
- Weakly supervised learning approaches for event detection
- Cross-sport generalization and domain adaptation studies

**Sports Analytics**:
- Performance analysis through automated player tracking
- Strategic pattern recognition in team sports
- Audience engagement measurement through content analysis
- Broadcast quality assessment and enhancement techniques

## Citation and Academic Attribution

When utilizing this dataset for research purposes, please acknowledge our contributions using the following citations:

### Primary Dataset Publication
```bibtex
@article{DBLP:journals/npl/KhanSAT20,
  author       = {Abdullah Aman Khan and
                  Jie Shao and
                  Waqar Ali and
                  Saifullah Tumrani},
  title        = {Content-Aware Summarization of Broadcast Sports Videos: An Audio-Visual
                  Feature Extraction Approach},
  journal      = {Neural Process. Lett.},
  volume       = {52},
  number       = {3},
  pages        = {1945--1968},
  year         = {2020},
  doi          = {10.1007/s11063-020-10251-4}
}
```

### Scorebox Detection Methodology
```bibtex
@inproceedings{khan2020detection,
  title        = {Detection and localization of scorebox in long duration broadcast sports videos},
  author       = {Khan, Abdullah Aman and Lin, Haoyang and Tumrani, Saifullah and Wang, Zheng and Shao, Jie},
  booktitle    = {International Symposium on Artificial Intelligence and Robotics 2020},
  volume       = {11574},
  pages        = {161--172},
  year         = {2020},
  organization = {SPIE},
  doi          = {10.1117/12.2580206}
}
```

## Technical Implementation and Future Development

### Current Implementation Status

The repository currently provides comprehensive dataset access and annotation frameworks, with ongoing development of associated computational tools and evaluation benchmarks. Future releases will include reference implementations for baseline algorithms, standardized evaluation protocols, and expanded annotation coverage across additional sports categories.

### Planned Enhancements

**Algorithmic Contributions**: Development of novel deep learning architectures specifically optimized for sports video analysis, including attention mechanisms for temporal modeling and multi-scale feature extraction approaches for handling diverse spatial resolutions across sports categories.

**Evaluation Frameworks**: Implementation of standardized benchmarking protocols enabling fair comparison across different methodological approaches, with particular emphasis on computational efficiency metrics relevant for real-time broadcasting applications.

**Dataset Expansion**: Ongoing efforts to incorporate additional sports categories and extended temporal coverage, with particular focus on emerging sports and international competitions that broaden the dataset's global applicability.

## Contact and Collaboration

**Primary Contact**: Abdullah Aman Khan  
**Email**: `abdkhan@std.uestc.edu.cn`

We welcome collaborative opportunities with researchers working on related problems in computer vision, sports analytics, and broadcast technology. While response times may vary due to research commitments, we prioritize supporting the academic community's utilization of this resource for advancing the state-of-the-art in sports video understanding.

For technical support, dataset access issues, or research collaboration inquiries, please reach out through the provided contact information. We particularly encourage researchers to share their findings and methodological innovations developed using this dataset to foster continued advancement in this rapidly evolving research domain.

---

**Acknowledgments**: This research was supported by institutional funding and collaborative efforts across multiple universities. We gratefully acknowledge the technical infrastructure provided by our institutional partners and the valuable feedback from the computer vision research community that helped refine this dataset's design and implementation.
