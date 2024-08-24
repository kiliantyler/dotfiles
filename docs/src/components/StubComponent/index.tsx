import React from 'react';
import styles from './styles.module.css';

interface StubComponentProps {
  title: string;
  iconStyle?: React.CSSProperties;
}

const StubComponent: React.FC<StubComponentProps> = ({ title }) => {
  return (
    <div>
      <h1>
      <span style={{ fontSize: '0.8em' }}>🚧</span> {title}
      </h1>
      <div className="hero shadow--lw">
        <div className="container">
          <h1 className="hero__title">Coming Soon</h1>
          <p>We're working hard to create this page. Please check back later for updates.</p>
          <img src="/img/under_construction.svg" alt="Under Construction" className={styles.stubImage} />
        </div>
      </div>
    </div>
  );
};

export default StubComponent;