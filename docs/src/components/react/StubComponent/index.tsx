import img from '@assets/under_construction.svg';
import React from 'react';
import styles from './styles.module.css';

interface StubComponentProps {
  title: string;
  iconStyle?: React.CSSProperties;
}

const StubComponent: React.FC<StubComponentProps> = ({ title }) => {
  return (
    <div>
      <h1>Coming Soon</h1>
      <p>We're working hard to create this page. Please check back later for updates.</p>
      <img src={img.src} alt="Under Construction" className={styles.stubImage} />
    </div>
  );
};

export default StubComponent;
